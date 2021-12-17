/*
 *  AppDelegate.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import Network
import SwiftUI
import MLCommon
import CoreSmokestack

public class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
	
	// willFinishLaunchingWithOptions callback for debugging lifecycle state issues
	public func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		return true
	}
	
	// didFinishLaunchingWithOptions callback to claim UNUserNotificationCenterDelegate, check Sign In With Apple State, and registers for network reachability updates
	// Handles push notification via launchOptions if app is not running and user taps on notification
	public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		UNUserNotificationCenter.current().delegate = self
		SmokestackPermissions.shared.getSIWACredentialState()
		let networkMonitor = NWPathMonitor()
		networkMonitor.start(queue: .global())
		networkMonitor.pathUpdateHandler = { path in
			DispatchQueue.main.async {
				SmokestackFlags.shared.networkReachable = path.status == .satisfied
			}
		}
		return true
	}
	
	// Callback for successful APNS registration
	public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		let receivedDeviceToken = deviceToken.map { String(format: "%02x", $0)}.joined()
		if VaporClient.shared.deviceToken != receivedDeviceToken {
			VaporClient.shared.deviceToken = receivedDeviceToken
		}
		SmokestackFlags.shared.apnsRegistrationSuccess.guarantee(matches: true)
	}
	
	// Callback for failed APNS registration
	public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		SmokestackFlags.shared.apnsRegistrationSuccess = false
		MLLogger.error(error.localizedDescription)
	}
	
	// Callback for handling remote notifications
	public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		guard let apsPayload = userInfo["aps"] as? [String: AnyObject], apsPayload["content-available"] as? Int == 1, userInfo["data"] != nil else {
			completionHandler(.failed)
			return
		}
		guard let aps = userInfo["aps"] as? [String: AnyObject], aps["content-available"] as? Int == 1,
			  let data = try? JSONSerialization.data(withJSONObject: userInfo["data"] as Any),
			  let smokeReport = try? JSONDecoder().decode(SmokeReport.self, from: data) else {
				  MLLogger.error("data does not conform to SmokeReport.self")
				  completionHandler(.failed)
				  return
		}
		
		VaporClient.shared.handleSmokeReport(smokeReport)
		completionHandler(.newData)
	}
}
