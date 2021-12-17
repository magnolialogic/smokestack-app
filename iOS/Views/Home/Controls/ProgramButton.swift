/*
 *  ProgramButton.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI
import BottomSheet
import CoreSmokestack

struct ProgramButton: View {
	@EnvironmentObject var flags: SmokestackFlags
	@EnvironmentObject var smoker: SmokerClient
	@State var presetMode: SmokeMode = .idle
	@State var presetTime = 0
	
	let buttonSize: CGFloat = 80
	let buttonFontSize: CGFloat = 48
	
    var body: some View {
		VStack(alignment: .center, spacing: 20) {
			Button(action: {
				flags.presentSetTargetChoiceDialog = true
			}) {
				Image(systemName: "thermometer")
					.font(Font.system(size: buttonFontSize))
					.foregroundColor(smoker.program == nil ? .blue : .orange)
					.frame(width: buttonSize, height: buttonSize, alignment: .center)
			}
			.softButtonStyle(Circle(), textColor: .blue, pressedEffect: .hard)
			.confirmationDialog("Use preset or custom program?", isPresented: $flags.presentSetTargetChoiceDialog, titleVisibility: .visible) {
				Button("Preset") {
					flags.presentPresetTemperatureChoiceDialog = true
				}
				Button("Custom Program") {
					flags.presentCustomProgramSheet = true
				}
			}
			// TODO: Need to prompt user "How long?" and plug that response in to limit (2 hours, 6 hours, 12 hours, indefinite)
			.confirmationDialog("Cook at which temperature?", isPresented: $flags.presentPresetTemperatureChoiceDialog, titleVisibility: .visible) {
				Button("High (400°F)") {
					presetMode = .hold
					smoker.state.temps[.grillTarget] = Measurement(value: 400, unit: .fahrenheit)
					flags.presentPresetTimeChoiceDialog = true
				}
				Button("Medium (275°F)") {
					presetMode = .hold
					smoker.state.temps[.grillTarget] = Measurement(value: 275, unit: .fahrenheit)
					flags.presentPresetTimeChoiceDialog = true
				}
				Button("Low (225°F)") {
					presetMode = .hold
					smoker.state.temps[.grillTarget] = Measurement(value: 225, unit: .fahrenheit)
					flags.presentPresetTimeChoiceDialog = true
				}
				Button("Smoke (180°F)") {
					presetMode = .smoke
					smoker.state.temps[.grillTarget] = Measurement(value: 180, unit: .fahrenheit)
					flags.presentPresetTimeChoiceDialog = true
				}
			}
			.confirmationDialog("Cook for how long?", isPresented: $flags.presentPresetTimeChoiceDialog, titleVisibility: .visible) {
				Button("Indefinitely") {
					presetTime = 604800
					smoker.addNewProgram(mode: presetMode, trigger: .time, limit: presetTime, targetGrill: smoker.state.temps[.grillTarget]!)
					flags.presentPresetTemperatureChoiceDialog = false
				}
				Button("12 hours") {
					presetTime = 43200
					smoker.addNewProgram(mode: presetMode, trigger: .time, limit: presetTime, targetGrill: smoker.state.temps[.grillTarget]!)
					flags.presentPresetTemperatureChoiceDialog = false
				}
				Button("6 hours") {
					presetTime = 21600
					smoker.addNewProgram(mode: presetMode, trigger: .time, limit: presetTime, targetGrill: smoker.state.temps[.grillTarget]!)
					flags.presentPresetTemperatureChoiceDialog = false
				}
				Button("2 hours") {
					presetTime = 7200
					smoker.addNewProgram(mode: presetMode, trigger: .time, limit: presetTime, targetGrill: smoker.state.temps[.grillTarget]!)
					flags.presentPresetTemperatureChoiceDialog = false
				}
				Button("Cancel", role: .cancel, action: {
					presetMode = .idle
					smoker.state.temps[.grillTarget] = Measurement(value: 0, unit: .fahrenheit)
					presetTime = 0
					flags.presentPresetTemperatureChoiceDialog = false
				})
			}
			.bottomSheet(isPresented: $flags.presentCustomProgramSheet, detents: [.medium()]) {
				SetTargetSheet()
					.background(Color.Neumorphic.main)
			}
			
			Text(smoker.program == nil ? "SET UP" : "EDIT PROGRAM")
				.foregroundColor(Color.Neumorphic.secondary)
				.font(.system(size: 12))
		}
    }
}

struct SetTargetButton_Previews: PreviewProvider {
    static var previews: some View {
        ProgramButton()
    }
}
