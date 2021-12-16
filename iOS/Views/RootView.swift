/*
 *  RootView.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

struct RootView: View {
	@EnvironmentObject var flags: SmokestackFlags
	
	var body: some View {
		if flags.SIWASetupDone {
			SmokestackGlass()
		} else {
			FrontPorch()
				.background(Color.Neumorphic.main)	// Force the front porch to light
				.preferredColorScheme(.light)		// mode because we don't have a
				.ignoresSafeArea()					// dark mode splash asset yet ;_;
		}
	}
}

struct RootView_Previews: PreviewProvider {
	static var previews: some View {
		RootView()
			.previewDisplayName("RootView")
	}
}
