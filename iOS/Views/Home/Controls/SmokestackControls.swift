/*
 *  SmokestackControls.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI
import Neumorphic

struct SmokestackControls: View {	
	var body: some View {
		GeometryReader { proxy in
			VStack(alignment: .center, spacing: 0) {
				SettingsAndSummary()
					.padding(10)
					.frame(height: 40)
				
				Spacer()
				
				HStack(alignment: .center, spacing: 10) {
					Spacer()
					
					ProgramButton()
					
					Spacer()
					
					PowerButton()
					
					Spacer()
				}
				
				Spacer()
			}
			.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
		}
	}
}

struct SmokestackControls_Preview: PreviewProvider {
	static var previews: some View {
		SmokestackControls()
			.previewDisplayName("SmokestackControls")
	}
}
