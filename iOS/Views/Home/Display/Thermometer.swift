/*
 *  Thermometer.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

struct Thermometer: View {
	var hideFill: Bool
	let currentTemp: Measurement<UnitTemperature>
	let targetTemp: Measurement<UnitTemperature>
	
	private let cornerRadius: CGFloat = 10
	
	var body: some View {
		let overTemp: Bool = currentTemp.value > targetTemp.value + 2
		let happyTemp: Bool = (targetTemp.value - 2...targetTemp.value + 2).contains(currentTemp.value)
		let thermometerFill: LinearGradient = overTemp ? .overTempThermometer : happyTemp ? .happyThermometer : .nominalThermometer
		let heightCoefficient = Double.minimum(currentTemp.value / targetTemp.value, 1.0)
		
		GeometryReader { proxy in
			ZStack(alignment: .bottom) {
				RoundedRectangle(cornerRadius: cornerRadius).fill(Color.Neumorphic.main)
					.softInnerShadow(RoundedRectangle(cornerRadius: cornerRadius), darkShadow: Color.Neumorphic.darkShadow, lightShadow: Color.Neumorphic.lightShadow, spread: 0.3, radius: 2)
				
				VStack(alignment: .center, spacing: 0) {
					RoundedRectangle(cornerRadius: cornerRadius).fill(thermometerFill)
						.frame(width: proxy.size.width, height: proxy.size.height * heightCoefficient, alignment: .bottom)
						.hidden(hideFill)
				}
			}
		}
    }
}

struct Thermometer_Previews: PreviewProvider {
    static var previews: some View {
		Thermometer(hideFill: false, currentTemp: Measurement(value: 100, unit: .fahrenheit), targetTemp: Measurement(value: 150, unit: .fahrenheit))
    }
}
