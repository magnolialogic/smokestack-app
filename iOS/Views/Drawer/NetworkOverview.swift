/*
 *  NetworkOverview.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

struct NetworkOverview: View {
	@EnvironmentObject var flags: SmokestackFlags
	@EnvironmentObject var vapor: VaporClient
	@EnvironmentObject var smoker: SmokerClient
	
	init() {
		UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.Neumorphic.main)
		UISegmentedControl.appearance().backgroundColor = UIColor(Color.clear)
		UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color("SegmentedControlText"))], for: .normal)
		UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color("SegmentedControlText"))], for: .selected)
		UISegmentedControl.appearance()
	}
	
	var body: some View {
		GeometryReader { geometry in
			let inset = geometry.size.width / 3
			
			VStack(alignment: .center, spacing: 0) {
				HStack(alignment: .lastTextBaseline) {
					Text("Server:")
						.frame(width: inset, alignment: .trailing)
						.font(Font.subheadline.smallCaps())
						.foregroundColor(Color.Neumorphic.secondary)
					
					if flags.connected {
						Image(systemName: "checkmark.icloud.fill")
							.foregroundColor(.green)
					} else {
						Image(systemName: "xmark.icloud.fill")
							.foregroundColor(.red)
					}
					
					Text(flags.connected ? "Connected" : "Offline")
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.trailing, 20)
						.foregroundColor(Color.Neumorphic.secondary)
				}
				.frame(width: geometry.size.width, height: 30)
				
				if flags.connected {
					HStack(alignment: .lastTextBaseline) {
						Text("Version:")
							.frame(width: inset, alignment: .trailing)
							.font(Font.subheadline.smallCaps())
							.foregroundColor(Color.Neumorphic.secondary)
						
						Text(vapor.version)
							.frame(maxWidth: .infinity, alignment: .leading)
							.padding(.trailing, 20)
							.foregroundColor(Color.Neumorphic.secondary)
					}
					.frame(width: geometry.size.width, height: 30)
				}
				
				HStack(alignment: .lastTextBaseline) {
					Text("Smoker:")
						.frame(width: inset, alignment: .trailing)
						.font(Font.subheadline.smallCaps())
						.foregroundColor(Color.Neumorphic.secondary)
					
					if smoker.state.online {
						Image(systemName: "externaldrive.fill.badge.wifi")
							.foregroundColor(.green)
					} else {
						Image(systemName: "externaldrive.badge.wifi")
							.foregroundColor(.red)
					}
					
					Text(smoker.state.online ? "Online" : "Offline")
						.frame(maxWidth: .infinity, alignment: .leading)
						.foregroundColor(Color.Neumorphic.secondary)
				}
				.frame(width: geometry.size.width, height: 30)
				.padding(.top, 20)
				.hidden(!flags.connected)
				
				HStack(alignment: .lastTextBaseline) {
					Text("Version:")
						.frame(width: inset, alignment: .trailing)
						.font(Font.subheadline.smallCaps())
						.foregroundColor(Color.Neumorphic.secondary)
					
					Text(smoker.version)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.trailing, 20)
						.foregroundColor(Color.Neumorphic.secondary)
				}
				.frame(width: geometry.size.width, height: 30)
				.hidden(!smoker.state.online)
				
				HStack(alignment: .lastTextBaseline) {
					Text("Units:")
						.frame(width: inset, alignment: .trailing)
						.font(Font.subheadline.smallCaps())
						.foregroundColor(Color.Neumorphic.secondary)
					
					Picker(selection: $flags.useCelsius, label: Text("Celsius preference")) {
						Text("°F").tag(0)
						Text("°C").tag(1)
					}
					.pickerStyle(SegmentedPickerStyle())
					.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 60))
				}
				.frame(width: geometry.size.width, height: 30)
				.padding(.top, 20)
				.hidden(!smoker.state.online)
				
				Spacer()
			}
		}
	}
}

struct NetworkOverview_Previews: PreviewProvider {
    static var previews: some View {
        NetworkOverview()
			.previewDisplayName("NetworkOverview")
    }
}
