/*
 *  Permissions.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import AuthenticationServices
import SwiftUI
import MLCommon
import CoreSmokestack

final class SmokestackPermissions: ObservableObject {
	private init() {}
	static let shared = SmokestackPermissions()
	
	@Published var notificationPermissionStatus = "Unknown" {
		didSet {
			MLLogger.debug(notificationPermissionStatus)
			if notificationPermissionStatus == "Allowed" && !SmokestackFlags.shared.apnsRegistrationSuccess {
				DispatchQueue.main.async {
					UIApplication.shared.registerForRemoteNotifications()
				}
			}
		}
	}
	
	func getNotificationAuthorizationStatus() {
		UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
			var status: String
			switch settings.authorizationStatus {
			case .notDetermined:
				status = "NotDetermined"
				self.requestNotificationsPermission()
			case .denied:
				status = "Denied"
			case .authorized, .provisional, .ephemeral:
				status = "Allowed"
			@unknown default:
				fatalError("getNotificationAuthorizationStatus(): Got unexpected value for getNotificationSettings \(String(describing: settings.authorizationStatus))")
			}
			DispatchQueue.main.async {
				self.notificationPermissionStatus.guarantee(matches: status)
			}
		})
	}
	
	func requestNotificationsPermission() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (allowed, error) in
			if allowed {
				MLLogger.debug("allowed, registering with APNS")
				DispatchQueue.main.async {
					UIApplication.shared.registerForRemoteNotifications()
				}
			} else if let error = error {
				MLLogger.error(error.localizedDescription)
			} else {
				MLLogger.warning("denied")
				DispatchQueue.main.async {
					self.notificationPermissionStatus = "Denied"
				}
			}
		}
	}
	
	func getSIWACredentialState() {
		if !VaporClient.shared.userID.isEmpty {
			guard let userIDBase64Data = Data(base64Encoded: VaporClient.shared.userID),
				  let userIDUTF8String = String(data: userIDBase64Data, encoding: .utf8) else {
				MLLogger.error("failed to decode Base64 Data from userID")
				return
			}
			let appleIDProvider = ASAuthorizationAppleIDProvider()
			appleIDProvider.getCredentialState(forUserID: userIDUTF8String) { (credentialState, error) in
				DispatchQueue.main.async {
					SmokestackFlags.shared.SIWASetupDone = credentialState == .authorized
				}
			}
		}
	}
}
