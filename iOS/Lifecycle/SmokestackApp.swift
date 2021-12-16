/*
 *  SmokestackApp.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

@main
struct SmokestackApp: App {
	@UIApplicationDelegateAdaptor var appDelegate: AppDelegate
	@StateObject var permissions = SmokestackPermissions.shared
	@StateObject var flags = SmokestackFlags.shared
	@StateObject var vapor = VaporClient.shared
	@StateObject var smoker = SmokerClient.shared
	
	var body: some Scene {
        WindowGroup {
			RootView()
				.environmentObject(permissions)
				.environmentObject(flags)
				.environmentObject(vapor)
				.environmentObject(smoker)
        }
    }
}
