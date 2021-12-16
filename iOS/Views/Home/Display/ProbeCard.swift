/*
 *  ProbeCard.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

struct ProbeCard: View {
	@EnvironmentObject var smoker: SmokerClient
	
    var body: some View {
		GeometryReader { geometry in
			NeumorphicCard(cornerRadius: 12) {
				ZStack(alignment: .center) {
					HStack(alignment: .center, spacing: 0) {
						Spacer()
						
						Thermometer(hideFill: false, currentTemp: smoker.state.temps[.probeCurrent] ?? Measurement(value: 0, unit: .fahrenheit), targetTemp: smoker.state.temps[.probeTarget] ?? Measurement(value: 0, unit: .fahrenheit))
							.frame(width: 24, height: geometry.size.height - 2, alignment: .trailing)
							.hidden(!smoker.state.probeConnected)
					}
					.frame(width: geometry.size.width - 2, height: geometry.size.height, alignment: .trailing)
					
					VStack(alignment: .center, spacing: 0) {
						HStack(alignment: .center, spacing: 0) {
							Image(systemName: "thermometer")
							
							Spacer()
								.frame(width: 5)
							
							Text("PROBE")
								.heading(alignment: .leading)
							
							Spacer()
						}
						.padding(10)
						.frame(width: geometry.size.width, height: 36, alignment: .leading)
						
						Spacer()
					}
					
					VStack(alignment: .leading, spacing: 0) {
						Spacer()
						
						TemperatureText(sensor: .probeCurrent)
							.frame(width: geometry.size.width - 20, height: 56, alignment: .bottomLeading)
						
						Text("CURRENT")
							.temperatureKey()
							.padding(.bottom, 10)
						
						TemperatureText(sensor: .probeTarget)
							.frame(width: geometry.size.width - 20, height: 28, alignment: .bottomLeading)
						
						Text("TARGET")
							.temperatureKey()
					}
					.padding(EdgeInsets(top: 0, leading: 12, bottom: 8, trailing: 20))
					.frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottomLeading)
					.hidden(!smoker.state.probeConnected)
					
					
					Text("DISCONNECTED")
						.font(.system(size: 12))
						.hidden(smoker.state.probeConnected)
				}
				.foregroundColor(Color.Neumorphic.secondary)
				.frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
			}
			.contextMenu {
				Button(action: {}, label: {Text("Set target")})
			}
		}
    }
}

struct ProbeCard_Previews: PreviewProvider {
    static var previews: some View {
		ProbeCard()
			.previewDisplayName("ProbeCard")
    }
}
