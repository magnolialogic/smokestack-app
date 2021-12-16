/*
 *  SmokestackGlass.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
*/

import Combine
import SwiftUI
import Neumorphic

struct SmokestackGlass: View {
	@EnvironmentObject var permissions: SmokestackPermissions
	@EnvironmentObject var flags: SmokestackFlags
	@EnvironmentObject var vapor: VaporClient
	@EnvironmentObject var smoker: SmokerClient
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .center) {
				VStack(alignment: .center, spacing: 0) {
					SmokestackStatus()
						.padding(.top, geometry.safeAreaInsets.top)
						.frame(width: geometry.size.width - 40, height: geometry.size.height * 0.52, alignment: .center)
					
					SmokestackControls()
				}
				.disabled(!smoker.state.online)
				
				VisualEffectBlur(blurStyle: .systemUltraThinMaterial, vibrancyStyle: .fill) {
					OfflineOverlay().hidden(!flags.setupDone)
				}
				.hidden(smoker.state.online)
				.frame(width: geometry.size.width)
				.ignoresSafeArea()
				
				VStack {
					Text("Please enable push notifications")
						.font(Font.footnote.smallCaps())
						.padding(.bottom, 12)
					
					Button(action: {
						UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
					}, label: {
						Text("Launch iOS Settings app")
							.font(Font.caption)
					})
				}
				.hidden(permissions.notificationPermissionStatus != "Denied")
				
				Button(action: {
					flags.presentDrawer = true
				}) {
					Text("set up smoker →")
						.frame(width: geometry.size.width - 40, height: 100, alignment: .leading)
						.font(Font.largeTitle.weight(.black))
				}
				.hidden(flags.setupDone || permissions.notificationPermissionStatus == "Denied")
			}
			.sheet(isPresented: $flags.presentDrawer) {
				Drawer()
					.background(Color.Neumorphic.main)
			}
			.background(Color.Neumorphic.main)
			.edgesIgnoringSafeArea(.all)
			// MARK: UIApplication lifecycle notifications
			.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
				permissions.getNotificationAuthorizationStatus()
				if flags.setupDone && flags.connected && !vapor.webSocket.connected {
					vapor.webSocket.connect()
				}
			}
			.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
				if flags.connected {
					vapor.webSocket.socket?.disconnect()
				}
			}
		}
	}
}

struct SmokestackHome_Previews: PreviewProvider {
	static var previews: some View {
		SmokestackGlass()
			.previewDisplayName("SmokestackHome")
	}
}
