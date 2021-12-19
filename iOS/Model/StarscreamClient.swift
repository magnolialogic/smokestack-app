/*
 *  StarscreamClient.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import Foundation
import Starscream
import MLCommon
import CoreSmokestack

class StarscreamClient: WebSocketDelegate {
	var connected = false {
		didSet {
			MLLogger.console(String(describing: connected))
			if connected {
				retryConnection = true
			} else if retryConnection { // If disconnected, retry connection once (in case of server restart)
				retryConnection = false
				connect()
			}
		}
	}
	
	var retryConnection = true
	
	var socket: WebSocket?
	
	func connect() {
		let requestURLString = VaporClient.shared.url.components(separatedBy: "://")[0].replacingOccurrences(of: "http", with: "ws") + "://" + VaporClient.shared.url.components(separatedBy: "://")[1] + "/api/client/upgrade" // Change scheme from http(s) -> ws(s) and add route
		let requestURL = URL(string: requestURLString)!
		MLLogger.console(String(describing: requestURL))
		var wsRequest = URLRequest(url: requestURL)
		wsRequest.setBasicAuth(username: "app", password: VaporClient.shared.secretKey)
		self.socket = WebSocket(request: wsRequest)
		self.socket?.delegate = self
		socket?.connect()
	}
	
	func didReceive(event: WebSocketEvent, client: WebSocketClient) {
		switch event {
		case .connected(_):
			self.connected = true
		case .cancelled:
			MLLogger.console("cancelled")
			self.connected = false
		case .disconnected(let reason, let code):
			MLLogger.console("disconnected \(reason) with code \(code)")
			self.connected = false
		case .binary(let data):
			do {
				let smokeReport = try JSONDecoder().decode(SmokeReport.self, from: data)
				VaporClient.shared.handleSmokeReport(smokeReport)
			} catch {
				MLLogger.error("binary data does not conform to WebSocketReport.self")
			}
		case .viabilityChanged(let viability):
			MLLogger.debug("viable: \(String(describing: viability))")
		case .reconnectSuggested(let suggestion):
			MLLogger.console("reconnect suggested \(String(describing: suggestion))")
		case .error(let error):
			var message: String
			if let e = error as? WSError {
				message = e.message
			} else if let e = error {
				message = e.localizedDescription
			} else {
				message = "unhandled error"
			}
			MLLogger.error(message)
			self.connected = false
		default: // .ping(_), .pong(_), .text(_)
			break
		}
	}
}
