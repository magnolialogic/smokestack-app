/*
 *  TemperatureText.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI
import CoreSmokestack

struct TemperatureText: View {
	@EnvironmentObject var smoker: SmokerClient
	
	let sensor: SmokeSensorKey
	
	var body: some View {
		let temperatureText: String = {
			guard let temperature = smoker.getLocalizedTemperature(for: sensor) else {
				return "NA"
			}
			switch temperature {
			case let value where value <= 0:
				return "NA"
			case let value where value <= 50:
				return "LOW"
			case let value where value > 50:
				return Int(value).description + "°"
			default:
				return "NA"
			}
		}()
		
		Text(temperatureText)
			.temperatureValue(type: sensor)
	}
}


struct TemperatureText_Previews: PreviewProvider {
    static var previews: some View {
		TemperatureText(sensor: .grillCurrent)
			.previewDisplayName("TemperatureText")
    }
}
