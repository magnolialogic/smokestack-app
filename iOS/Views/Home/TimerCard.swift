/*
 *  TimerCard.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

struct TimerCard: View {
	@EnvironmentObject var smoker: SmokerClient
	
	func setTemp(grill: Int, probe: Int) {
		smoker.state.temps[.grillCurrent] = Measurement(value: Double(grill), unit: .fahrenheit)
		smoker.state.temps[.probeCurrent] = Measurement(value: Double(probe), unit: .fahrenheit)
	}
	
    var body: some View {
		GeometryReader { geometry in
			Menu {
				Button("15 mins", action: {
					setTemp(grill: 72, probe: 72)
				})
				Button("1 hour", action: {
					setTemp(grill: 223, probe: 134)
				})
				Button("4 hours", action: {
					setTemp(grill: 225, probe: 145)
				})
				Button("12 hours", action: {
					setTemp(grill: 228, probe: 152)
				})
			} label: {
				NeumorphicCard(cornerRadius: 12) {
					Text("SET TIMER")
						.foregroundColor(Color.Neumorphic.secondary)
						.font(.system(size: 12))
				}
			}
			.disabled(!smoker.state.power)
		}
    }
}

struct TimerCard_Previews: PreviewProvider {
    static var previews: some View {
        TimerCard()
    }
}
