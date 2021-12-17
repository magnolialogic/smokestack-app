/*
 *  Status.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import Combine
import SwiftUI

struct Status: View {
	@EnvironmentObject var flags: SmokestackFlags
	@EnvironmentObject var smoker: SmokerClient
	
	@State var grillTargetTempSelectionIndex = 0
	@State var probeTargetTempSelectionIndex = 0
	
	private func handleGrillSelectionChange(_ index: Int) {
		let targetTemps = [150, 180, 225, 250, 275, 300] // TODO: support celsius
		smoker.state.temps[.grillTarget] = Measurement(value: Double(targetTemps[index]), unit: .fahrenheit)
	}
	
	private func handleProbeSelectionChange(_ index: Int) {
		let targetTemps = [0, 145, 160, 165, 195, 200]  // TODO: support celsius
		smoker.state.temps[.probeTarget] = Measurement(value: Double(targetTemps[index]), unit: .fahrenheit)
	}
	
	var body: some View {
		GeometryReader { proxy in
			let legendWidth: CGFloat = (proxy.size.width - 20)/2
			let legendHeight: CGFloat = 180
			
			VStack(alignment: .center) {
				Spacer()
				
				HStack(alignment: .center, spacing: 0) {
					Menu {
						Picker(selection: $grillTargetTempSelectionIndex.onChange(handleGrillSelectionChange), label: Text("Select target grill temperature")) {
							Text("150°").tag(0)
							Text("180°").tag(1)
							Text("225°").tag(2)
							Text("250°").tag(3)
							Text("275°").tag(4)
							Text("300°").tag(5)
						}
					} label: {
						GrillCard()
							.frame(width: legendWidth, height: legendHeight, alignment: .center)
					}
					.disabled(!smoker.state.power)
					
					Spacer()
					
					Menu {
						Picker(selection: $probeTargetTempSelectionIndex.onChange(handleProbeSelectionChange), label: Text("Select target probe temperature")) {
							Text("No target").tag(0)
							Divider()
							Text("145°F").tag(1)
							Text("160°F").tag(2)
							Text("165°F").tag(3)
							Text("195°F").tag(4)
							Text("200°F").tag(5)
						}
					} label: {
						ProbeCard()
							.frame(width: legendWidth, height: legendHeight, alignment: .center)
					}
					.disabled(!smoker.state.probeConnected)
				}
				.disabled(!flags.connected)
				
				Spacer()
			}
		}
	}
}

struct Status_Previews: PreviewProvider {
	static var previews: some View {
		Status()
			.previewDisplayName("Status")
	}
}
