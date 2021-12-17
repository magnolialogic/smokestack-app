/*
 *  SettingsView.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

struct SettingsView: View {
	@EnvironmentObject var flags: SmokestackFlags
	@EnvironmentObject var vapor: VaporClient
	
	var body: some View {
		GeometryReader { geometry in
			VStack(alignment: .center, spacing: 0) {
				NeumorphicCard(cornerRadius: 12) {
					VStack(spacing: 0) {
						VStack(alignment: .leading, spacing: 0) {
							Text(URLComponents(string: vapor.url)?.host ?? "")
								.font(Font.headline.smallCaps())
								.foregroundColor(Color.Neumorphic.secondary)
								.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 10))
								.truncationMode(.tail)
							
							Divider()
								.padding(.leading, 20)
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						
						NetworkOverview()
							.padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
						
						Spacer()
					}
					.foregroundColor(Color.Neumorphic.secondary)
					
					Spacer()
				}
				.frame(width: geometry.size.width - 40, height: 280, alignment: .center)
				
				Spacer()
				
				Button(action: {
					flags.presentDisconnectConfirmationDialog = true
				}, label: {
					Text("Disconnect")
						.fontWeight(.heavy)
						.frame(width: 150, height: 25)
				})
				.softButtonStyle(Capsule(), padding: 20, textColor: .red, pressedEffect: .hard)
				.confirmationDialog("Are you sure?", isPresented: $flags.presentDisconnectConfirmationDialog, titleVisibility: .visible) {
					Button("Yes", role: .destructive) {
						vapor.logout()
						try? vapor.nukeKeychain()
						vapor.finishSetup(false)
					}
				}
				
				Spacer()
				
				FooterView()
			}
		}
	}
}

struct Settings_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
			.previewDisplayName("SettingsView")
	}
}
