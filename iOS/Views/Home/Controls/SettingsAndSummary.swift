/*
 *  SettingsAndSummary.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

struct SettingsAndSummary: View {
	@EnvironmentObject var flags: SmokestackFlags
	@EnvironmentObject var smoker: SmokerClient
	
	@State private var presentingOnlinePopover = false
	
    var body: some View {
		GeometryReader { proxy in
			HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 0) {
				Button(action: {
					flags.presentDrawer = true
				}) {
					Image(systemName: "gearshape")
				}
				.softButtonStyle(Circle(), padding: 5, textColor: .blue, pressedEffect: .flat)
				
				Text(smoker.summary)
					.font(Font.subheadline.smallCaps())
					.foregroundColor(Color.Neumorphic.secondary)
					.padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 20))
				
				Spacer()
			}
			.padding(EdgeInsets(top: 15, leading: 10, bottom: 10, trailing: 0))
		}
    }
}

struct SettingsAndSummary_Previews: PreviewProvider {
    static var previews: some View {
        SettingsAndSummary()
			.previewDisplayName("SettingsAndSummary")
    }
}
