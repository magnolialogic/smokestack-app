/*
 *  OfflineOverlay.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

struct OfflineOverlay: View {
	@EnvironmentObject var flags: SmokestackFlags
	
    var body: some View {
		VStack(alignment: .center) {
			Spacer()
			
			ProgressView()
				.scaleEffect(2.5, anchor: .center)
				.padding(.bottom, 40)
			
			HStack(spacing: 5) {
				Text("\(flags.connected ? "Smoker" : "Server") offline")
					.font(Font.footnote.smallCaps())
				
				Button(action: {
					flags.presentDrawer = true
				}) {
					Image(systemName: "gearshape")
				}
			}
			
			Spacer()
		}
    }
}

struct OfflineOverlay_Previews: PreviewProvider {
    static var previews: some View {
        OfflineOverlay()
			.previewDisplayName("OfflineOverlay")
    }
}
