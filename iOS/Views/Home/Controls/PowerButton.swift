/*
 *  PowerButton.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

struct PowerButton: View {
	@EnvironmentObject var flags: SmokestackFlags
	@EnvironmentObject var smoker: SmokerClient
	
	let buttonSize: CGFloat = 80
	let buttonFontSize: CGFloat = 56
	
    var body: some View {
		VStack(alignment: .center, spacing: 20) {
			Button(action: {
				if smoker.state.power {
					flags.presentShutdownConfirmationDialog = true
				} else {
					smoker.state.temps = [
						.grillCurrent: Measurement(value: 72, unit: .fahrenheit),
						.grillTarget: Measurement(value: 150, unit: .fahrenheit),
						.probeCurrent: Measurement(value: 134, unit: .fahrenheit),
						.probeTarget: Measurement(value: 0, unit: .fahrenheit)
					]
					smoker.summary = "Warming up..." // TODO: if smoker.program[smoker.programIndex] == "Start" { "Warming up..." } else { .summary() }
					smoker.state.power = true
				}
			}) {
				Image(systemName: smoker.state.power ? "xmark.octagon.fill" : "power")
					.font(Font.system(size: buttonFontSize))
					.foregroundColor(smoker.program == nil ? Color.Neumorphic.lightShadow : smoker.state.power ? .red : .blue)
					.frame(width: buttonSize, height: buttonSize, alignment: .center)
			}
			.softButtonStyle(Circle(), textColor: .blue, pressedEffect: .hard)
			.disabled(smoker.program == nil)
			.confirmationDialog("Are you sure?", isPresented: $flags.presentShutdownConfirmationDialog, titleVisibility: .visible) {
				Button("Yes", role: .destructive) {
					smoker.state.temps = [
						.grillCurrent: Measurement(value: 72, unit: .fahrenheit),
						.grillTarget: Measurement(value: 0, unit: .fahrenheit),
						.probeCurrent: Measurement(value: 0, unit: .fahrenheit),
						.probeTarget: Measurement(value: 0, unit: .fahrenheit)
					]
					smoker.summary = "Online"
					smoker.program = nil
					smoker.state.power = false
				}
			}
			
			Text(smoker.state.power ? "SHUT DOWN" : "POWER")
				.foregroundColor(Color.Neumorphic.secondary)
				.opacity(smoker.program == nil ? 0.33 : 1.0)
				.font(.system(size: 12))
		}
    }
}

struct PowerButton_Previews: PreviewProvider {
    static var previews: some View {
        PowerButton()
    }
}
