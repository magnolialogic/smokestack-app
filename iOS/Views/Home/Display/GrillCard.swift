/*
 *  GrillCard.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

struct GrillCard: View {
	@EnvironmentObject var smoker: SmokerClient
	
    var body: some View {
		GeometryReader { geometry in
			NeumorphicCard(cornerRadius: 12) {
				ZStack(alignment: .center) {
					HStack(alignment: .center, spacing: 0) {
						Spacer()
						
						Thermometer(
							hideFill: !smoker.state.power,
							currentTemp: smoker.state.temps[.grillCurrent] ?? Measurement(value: 0, unit: .fahrenheit),
							targetTemp: smoker.state.temps[.grillTarget] ?? Measurement(value: 0, unit: .fahrenheit))
							.frame(width: 24, height: geometry.size.height - 2, alignment: .trailing)
					}
					.frame(width: geometry.size.width - 2, height: geometry.size.height, alignment: .trailing)
					
					VStack(alignment: .center, spacing: 0) {
						HStack(alignment: .center, spacing: 0) {
							Image(systemName: "flame")
							
							Spacer()
								.frame(width: 5)
							
							Text("GRILL")
								.heading(alignment: .leading)
							
							Spacer()
						}
						.padding(8)
						.frame(width: geometry.size.width, height: 36, alignment: .topLeading)
						
						Spacer()
					}
					
					VStack(alignment: .leading, spacing: 0) {
						Spacer()
						
						TemperatureText(sensor: .grillCurrent)
							.frame(width: geometry.size.width - 40, height: 47, alignment: .bottomLeading)
							.padding(.bottom, 0)
						
						Text("CURRENT")
							.temperatureKey()
							.padding(.bottom, 12)
						
						Text("\(smoker.state.temps[.grillCurrent]?.formatted() ?? "NA")")
							.temperatureValue(type: .grillTarget)
							.frame(width: geometry.size.width - 40, height: 25, alignment: .bottomLeading)
						
						Text("SET")
							.temperatureKey()
					}
					.padding(EdgeInsets(top: 0, leading: 12, bottom: 8, trailing: 40))
					.frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottomLeading)
				}
				.foregroundColor(Color.Neumorphic.secondary)
				.frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
			}
			.contextMenu {
				Button(action: {}, label: {Text("Set target")})
					.disabled(!smoker.state.probeConnected)
			}
		}
    }
}

struct GrillCard_Previews: PreviewProvider {
    static var previews: some View {
		GrillCard()
			.previewDisplayName("GrillCard")
    }
}
