/*
 *  Vapor.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import AuthenticationServices
import SwiftUI
import MLCommon
import CoreSmokestack

final class VaporClient: ObservableObject {
	private init() {
		if SmokestackFlags.shared.setupDone && SmokestackFlags.shared.networkReachable {
			Task {
				try await httpRegisterClient(true, server: url, secretKey: secretKey)
			}
		}
	}
	static let shared = VaporClient()
	
	let webSocket = StarscreamClient()
	
	var url = UserDefaults.standard.string(forKey: "vaporURL") ?? "" {
		didSet {
			MLLogger.debug(url)
			UserDefaults.standard.setValue(url, forKey: "vaporURL")
		}
	}
	
	var userID = UserDefaults.standard.string(forKey: "userID") ?? "" {
		didSet {
			MLLogger.debug(userID)
			UserDefaults.standard.setValue(userID, forKey: "userID")
		}
	}
	
	var secretKey: String {
		get {
			guard url.isValidURL else {
				MLLogger.error("url not valid!")
				return "" // TODO: what happens here with wrong password in saved config? can test by adding 1 character to end of key in Redis
			}
			do {
				let query = [ kSecClass as String: kSecClassGenericPassword,
							  kSecAttrService as String: url,
							  kSecReturnAttributes as String: true,
							  kSecReturnData as String: true
				] as CFDictionary
				
				var result: AnyObject?
				let status = SecItemCopyMatching(query, &result)
				
				guard status == errSecSuccess else { // TODO: do we even need to throw here? can we get rid of this do {} catch {}
					throw SmokeError.keychainSecItemCopy(status)
				}
				
				let credentials = result as! NSDictionary
				let passwordData = credentials[kSecValueData] as! Data
				let password = String(data: passwordData, encoding: .utf8)!
				
				return password
			} catch {
				MLLogger.error(error.localizedDescription)
				return "" // TODO
			}
		}
	}
	
	@Published var version: String = "Unknown" {
		didSet {
			MLLogger.console(version)
		}
	}
	
	var deviceToken = UserDefaults.standard.string(forKey: "deviceToken") ?? "uuid-\(UUID().uuidString)" {
		didSet {
			MLLogger.debug(deviceToken)
			UserDefaults.standard.setValue(deviceToken, forKey: "deviceToken")
		}
	}
}

// MARK: Methods

extension VaporClient {
	/*
	* finishSetup
	*
	* Called with success: false whenever setup process fails
	* Only called with success: true at end of setup process if:
	*	 	1. server URL + secretKey are valid
	*		2. secretKey has been saved to Keychain
	*
	* Finalizes setup status
	*/
	func finishSetup(_ success: Bool) {
		SmokestackFlags.shared.connected.guarantee(matches: success)
		SmokestackFlags.shared.setupDone.guarantee(matches: success)
		SmokestackFlags.shared.setupInProgress = false
	}
	
	func logout() {
		Task {
			try await httpRegisterClient(false, server: VaporClient.shared.url, secretKey: VaporClient.shared.secretKey)
		}
	}
}

// MARK: Keychain

extension VaporClient {
	func addCredentialsToKeychain(credentials: Credentials) throws {
		// Delete Smokestack keychain item if it exists
		var query = [kSecClass: kSecClassGenericPassword,
					 kSecAttrService: credentials.url
		] as CFDictionary
		SecItemDelete(query)
		
		// Add Smokestack keychain item
		query = [kSecClass as String: kSecClassGenericPassword,
				 kSecAttrService as String: credentials.url,
				 kSecAttrAccount as String: credentials.username,
				 kSecValueData as String: credentials.secretKey.data(using: .utf8)!,
				 kSecAttrLabel as String: "smokestack"
		] as CFDictionary
		let status = SecItemAdd(query, nil)
		guard status == errSecSuccess else { // TODO: do we even need to throw here? can we get rid of this do {} catch {}
			throw SmokeError.keychainSecItemAdd(status)
		}
		MLLogger.console("success")
	}
	
	func nukeKeychain() throws {
		// Destroy Smokestack keychain item
		guard url.isValidURL else {
			MLLogger.error("url not valid!")
			return
		}
		let smokestackQuery = [kSecClass: kSecClassGenericPassword, kSecAttrService: url] as CFDictionary
		SecItemDelete(smokestackQuery)
	}
}

// MARK: Networking methods

extension VaporClient {
	/*
	 * httpRegisterClient
	 *
	 * Called with "true" (POST) when Connect button is tapped, on VaporClient.init() if setupDone && networkReachable, or upon networkReachable if setupDone && !connected. Saves VaporClient.url and sets VaporClient.connected if basic auth succeeds.
	 *
	 * Called with "false" (DELETE) when disconnect button is tapped
	 */
	func httpRegisterClient(_ register: Bool, server: String, secretKey: String) async throws {
		var serverURL: String
		if !SmokestackFlags.shared.setupDone {
			if server.contains("://") {
				serverURL = server.components(separatedBy: "://")[1]
			} else {
				serverURL = server
			}
			serverURL = "http://" + serverURL
		} else {
			serverURL = VaporClient.shared.url
		}
		guard let requestURL = URL(string: serverURL + "/api/client") else {
			MLLogger.error("failed to create request URL")
			return
		}
		
		var request = URLRequest(url: requestURL)
		request.httpMethod = register ? "POST" : "DELETE"
		request.setBasicAuth(username: "app", password: secretKey)
		request.setContentType("application/json")
		request.timeoutInterval = 10
		guard let httpBody = try? SmokestackToolbox.shared.jsonEncoder.encode(["deviceToken": VaporClient.shared.deviceToken]) else {
			MLLogger.error("failed to encode payload JSON")
			return
		}
		request.httpBody = httpBody
		
		let (data, response) = try await URLSession.shared.data(for: request)
		
		guard let response = response as? HTTPURLResponse else {
			MLLogger.error("failed to cast to HTTPURLResponse")
			return
		}
		
		MLLogger.console("\(request.httpMethod! as NSObject) \(requestURL) [responseCode: \(response.statusCode)]")
		
		await MainActor.run {
			if register && SmokestackFlags.shared.setupInProgress { // Finishing setup?
				guard response.statusCode == 200 else {
					finishSetup(false)
					return
				}
				VaporClient.shared.url = requestURL.scheme! + "://" +  requestURL.host!
				let credentials = Credentials(url: VaporClient.shared.url, username: VaporClient.shared.userID, secretKey: secretKey)
				do {
					try VaporClient.shared.addCredentialsToKeychain(credentials: credentials)
					finishSetup(true)
				} catch {
					MLLogger.error("failed to save data to keychain")
					finishSetup(false)
					return
				}
			} else if register && SmokestackFlags.shared.setupDone {
				if SmokestackFlags.shared.presentDrawer {
					SmokestackFlags.shared.presentDrawer = false
				}
				if SmokestackFlags.shared.connected != (response.statusCode == 200) {
					SmokestackFlags.shared.connected = response.statusCode == 200
				}
			} else { // !register
				return
			}
			if response.statusCode == 200 {
				guard let responseBody = try? SmokestackToolbox.shared.jsonDecoder.decode([String: String].self, from: data) else {
					MLLogger.error("Response body does not conform to [String: String].self")
					return
				}
				VaporClient.shared.version.guarantee(matches: responseBody["softwareVersion"] ?? "Unknown")
				if let firmwareVersion = responseBody["firmwareVersion"] {
					SmokerClient.shared.version.guarantee(matches: firmwareVersion)
				}
			}
		}
	}
	
	/*
	 * httpGetOnlineStatus
	 *
	 * Called when setup is complete, network is reachable, and app is connected to server
	 * Checks whether Smokestack firmware is connected to server, fetches firmware version if online
	 */
	func httpGetOnlineStatus() async throws {
		guard let requestURL = URL(string: VaporClient.shared.url + "/api/smoker/online") else {
			MLLogger.error("failed to create request URL")
			return
		}
		
		var request = URLRequest(url: requestURL)
		request.httpMethod = "GET"
		request.setBasicAuth(username: "app", password: VaporClient.shared.secretKey)
		request.setContentType("application/json")
		request.timeoutInterval = 10
		
		let (data, response) = try await URLSession.shared.data(for: request)
		
		guard let response = response as? HTTPURLResponse else {
			MLLogger.error("no response from vapor")
			return
		}
		
		await MainActor.run {
			let firmwareVersion = String(data: data, encoding: .utf8) ?? "Unknown"
			if response.statusCode == 200 {
				MLLogger.console("GET \(requestURL) [responseCode: \(response.statusCode), responseData: \"\(firmwareVersion)]\"")
			} else {
				MLLogger.console("GET \(requestURL) [responseCode: \(response.statusCode)]")
			}
			SmokerClient.shared.state.online.guarantee(matches: response.statusCode == 200)
			if SmokerClient.shared.state.online && !firmwareVersion.isEmpty {
				SmokerClient.shared.version = firmwareVersion
			}
			
		}
	}
	
	/*
	 * httpGetState
	 *
	 * Called when Session.webSocket.connected set to true
	 * Fetches remote state and maps to internal state
	 */
	func httpGetState() async throws {
		// Construct HTTP request
		guard let requestURL = URL(string: VaporClient.shared.url + "/api/state") else {
			MLLogger.error("failed to create request URL")
			return
		}
		
		var request = URLRequest(url: requestURL)
		request.httpMethod = "GET"
		request.setBasicAuth(username: "app", password: VaporClient.shared.secretKey)
		request.setContentType("application/json")
		request.timeoutInterval = 10
		
		let (data, response) = try await URLSession.shared.data(for: request)
		
		guard let response = response as? HTTPURLResponse else {
			MLLogger.error("no response from vapor")
			return
		}
		
		MLLogger.console(String(describing: response))
		
		let state = try SmokestackToolbox.shared.jsonDecoder.decode(SmokeState.self, from: data)
		if SmokerClient.shared.state != state {
			await MainActor.run {
				SmokerClient.shared.state = state
			}
		}
	}
}

// legacy
extension VaporClient {
	func getProgram() {
		// Construct HTTP request
		guard let requestURL = URL(string: VaporClient.shared.url + "/api/program") else {
			MLLogger.error("failed to create request URL")
			return
		}
		var request = URLRequest(url: requestURL)
		request.httpMethod = "GET"
		request.setValue("application/json", forHTTPHeaderField: "content-type")
		request.timeoutInterval = 10
		let authorizationCredentials = "app:\(VaporClient.shared.secretKey)".data(using: .utf8)!.base64EncodedString()
		request.setValue("Basic \(authorizationCredentials)", forHTTPHeaderField: "Authorization")
		
		// Send HTTP request
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			guard error == nil else {
				MLLogger.error(error!.localizedDescription)
				return
			}
			guard let response = response as? HTTPURLResponse else {
				MLLogger.error("no response from vapor")
				return
			}
			
			var steps: [SmokeStep] = []
			
			if response.statusCode == 200 {
				guard let data = data else {
					MLLogger.error("status 200 but no response data")
					return
				}
				do {
					let stepData = try SmokestackToolbox.shared.jsonDecoder.decode([SmokeStep].self, from: data)
					MLLogger.console("\(request.httpMethod! as NSObject) \(requestURL) [responseCode: \(response.statusCode), responseData: \(stepData)]")
					for entry in stepData {
						steps.append(entry)
					}
				} catch {
					MLLogger.error("\(error as NSObject)")
				}
			} else {
				MLLogger.console("\(request.httpMethod! as NSObject) \(requestURL) [responseCode: \(response.statusCode)]")
			}
			
			DispatchQueue.main.async {
				if steps != SmokerClient.shared.program?.steps {
					SmokerClient.shared.program = SmokeProgram(steps: steps)
				}
			}
		}.resume()
	}
	
	func pushProgram() {
		// Construct HTTP request
		guard let requestURL = URL(string: VaporClient.shared.url + "/api/program") else {
			MLLogger.error("failed to create request URL")
			return
		}
		
		var request = URLRequest(url: requestURL)
		request.setValue("application/json", forHTTPHeaderField: "content-type")
		request.timeoutInterval = 10
		let authorizationCredentials = "app:\(VaporClient.shared.secretKey)".data(using: .utf8)!.base64EncodedString()
		request.setValue("Basic \(authorizationCredentials)", forHTTPHeaderField: "Authorization")
		
		if SmokerClient.shared.program != nil {
			request.httpMethod = "POST"
			do {
				let httpRequestData = try SmokestackToolbox.shared.jsonEncoder.encode(SmokerClient.shared.program)
				request.httpBody = httpRequestData
			} catch {
				MLLogger.error("failed to encode JSON")
				return
			}
		} else {
			request.httpMethod = "DELETE"
		}
		
		// Send HTTP request
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			guard error == nil else {
				MLLogger.error(error!.localizedDescription)
				return
			}
			guard let response = response as? HTTPURLResponse else {
				MLLogger.error("no response from vapor")
				return
			}
			
			MLLogger.console("\(request.httpMethod! as NSObject) \(requestURL)\(request.httpMethod == "POST" ? " [requestData: \(SmokerClient.shared.program!)" : ""), responseCode: \(response.statusCode)]") // TODO: String(describing:
		}.resume()
	}
	
	func runProgram(_ run: Bool) {
		guard SmokerClient.shared.program != nil else {
			MLLogger.error("no program data!")
			return
		}
		
		if run {
			pushProgram()
		}
		
		// Construct HTTP request
		guard let requestURL = URL(string: VaporClient.shared.url + "/api/settings") else {
			MLLogger.error("failed to create request URL")
			return
		}
		
		let body = [
			"criticalProgramUpdate": 1,
			"program": run ? 1 : 0
		]
		
		var request = URLRequest(url: requestURL)
		request.httpMethod = "PATCH"
		request.setValue("application/json", forHTTPHeaderField: "content-type")
		request.timeoutInterval = 10
		let authorizationCredentials = "app:\(VaporClient.shared.secretKey)".data(using: .utf8)!.base64EncodedString()
		request.setValue("Basic \(authorizationCredentials)", forHTTPHeaderField: "Authorization")
		guard let httpBody = try? SmokestackToolbox.shared.jsonEncoder.encode(body) else {
			MLLogger.error("failed to encode payload JSON \(body)")
			return
		}
		request.httpBody = httpBody
		
		// Send HTTP request
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			guard error == nil else {
				MLLogger.error(error!.localizedDescription)
				return
			}
			guard let response = response as? HTTPURLResponse else {
				MLLogger.error("no response from vapor")
				return
			}
			
			guard response.statusCode == 200 else {
				MLLogger.console("\(request.httpMethod! as NSObject) \(requestURL) [responseCode: \(response.statusCode)]")
				return
			}
			
			MLLogger.console("\(request.httpMethod! as NSObject) \(requestURL) [responseCode: \(response.statusCode)]")
			
			DispatchQueue.main.async {
				SmokestackFlags.shared.runningProgram = run
			}
		}.resume()
	}
	
	func setPower(_ run: Bool) {
		// Construct HTTP request
		let endpoint = run ? "/api/smoker/start" : "/api/smoker/stop"
		guard let requestURL = URL(string: VaporClient.shared.url + endpoint) else {
			MLLogger.error("failed to create request URL")
			return
		}
		
		var request = URLRequest(url: requestURL)
		request.httpMethod = "POST"
		request.timeoutInterval = 10
		let authorizationCredentials = "app:\(VaporClient.shared.secretKey)".data(using: .utf8)!.base64EncodedString()
		request.setValue("Basic \(authorizationCredentials)", forHTTPHeaderField: "Authorization")
		
		// Send HTTP request
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			guard error == nil else {
				MLLogger.error(error!.localizedDescription)
				return
			}
			guard let response = response as? HTTPURLResponse else {
				MLLogger.error("no response from vapor")
				return
			}
			
			guard response.statusCode == 200 else {
				MLLogger.console("\(request.httpMethod! as NSObject) \(requestURL) [responseCode: \(response.statusCode)]")
				return
			}
			
			MLLogger.console("\(request.httpMethod! as NSObject) \(requestURL) [responseCode: \(response.statusCode)]")
			
			DispatchQueue.main.async {
				SmokerClient.shared.state.power = run
			}
		}.resume()
	}
}

extension VaporClient {
	func handleSmokeReport(_ report: SmokeReport) {
		MLLogger.debug("id: \(report.id)")
		if !SmokestackFlags.shared.connected {
			SmokestackFlags.shared.connected = true
		}
		if let temps = report.temps {
			DispatchQueue.main.async {
				if SmokerClient.shared.state.probeConnected != (temps.probe != nil) {
					SmokerClient.shared.state.probeConnected = temps.probe != nil
				}
				SmokerClient.shared.state.temps[.grillCurrent] = Measurement(value: Double(temps.grill), unit: .fahrenheit)
				if let probeTemp = temps.probe {
					SmokerClient.shared.state.temps[.probeCurrent] = Measurement(value: Double(probeTemp), unit: .fahrenheit)
				}
			}
		}
		
		if let state = report.state, SmokerClient.shared.state != state {
			SmokeState.shared.apply(update: state, to: SmokerClient.shared.state)
		}
		
		if let statePatch = report.statePatch {
			SmokeState.shared.apply(update: statePatch, to: SmokerClient.shared.state)
		}
		
		if let steps = report.program?.steps, SmokerClient.shared.program?.steps != steps {
			SmokerClient.shared.program?.steps = steps
		}
		
		if let timerFired = report.timerFired {
			MLLogger.debug("Timer fired!")
		}
		
		if let softwareVersion = report.softwareVersion {
			if VaporClient.shared.version != softwareVersion {
				VaporClient.shared.version = softwareVersion
			}
		}
		
		if let firmwareVersion = report.firmwareVersion {
			if SmokerClient.shared.version != firmwareVersion {
				SmokerClient.shared.version = firmwareVersion
			}
			if !SmokerClient.shared.state.online {
				SmokerClient.shared.state.online = true
			}
		}
	}
}
