/*
 *  OfflineOverlay.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

struct Drawer: View {
	@EnvironmentObject var flags: SmokestackFlags
	
    var body: some View {
		GeometryReader { geometry in
			let screenWidth = geometry.size.width
			
			ZStack {
				VStack {
					Grabber()
					
					Spacer()
				}
				
				SettingsView()
					.padding(.top, 40)
					.hidden(!flags.setupDone)
				
				LoginView()
					.padding(.top, 40)
					.hidden(flags.setupDone)
			}
			.frame(width: screenWidth)
		}
    }
}

struct Drawer_Previews: PreviewProvider {
    static var previews: some View {
        Drawer()
    }
}
