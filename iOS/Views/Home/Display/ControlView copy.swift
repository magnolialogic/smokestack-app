//
//  ControlView.swift
//  smokestack
//
//  Created by Chris Coffin on 5/11/21.
//

import SwiftUI

struct ControlView: View {
	@EnvironmentObject var smoker: Smoker
	
	@State private var powerButtonImageIdentifier = "power"
	@State private var powerButtonString = "Power On"
	@State private var runButtonImageIdentifier = "play.fill"
	@State private var runButtonString = "Start"
	@State private var keepWarmButtonString = "Keep warm"
	@State private var presentingProgramResetDialog = false
	@State private var presentingPowerResetDialog = false
	
	let buttonSize: CGFloat = 56
	
	var body: some View {
		VStack(alignment: .center, spacing: 0) {
			
//			HStack {
//				Button(action: {
//					if smoker.program.count == 0 {
//						smoker.addNewProgram(mode: "Hold", trigger: "Temp", limit: 165, targetGrill: 225)
//					} else {
//						smoker.program = []
//					}
//				}) {
//					Text("Status".uppercased())
//						.heading(alignment: .leading)
//						.frame(maxWidth: .infinity, alignment: .leading)
//						.font(.system(size: 12, weight: .bold, design: .default))
//						.foregroundColor(.primary)
//				}
//				
//				if smoker.isRunningProgram && smoker.program.count > 0 {
//					Button(action: {
//						presentingProgramResetDialog = true
//					}) {
//						Text("Reset program".uppercased())
//							.heading(alignment: .trailing)
//							.frame(maxWidth: .infinity, alignment: .trailing)
//					}
//					.alert(isPresented: $presentingProgramResetDialog) {
//						Alert(title: Text("Confirm"), message: Text("Abandon current program?"), primaryButton: .destructive(Text("Reset")) {
//							smoker.program = []
//							smoker.isRunningProgram = false
//						}, secondaryButton: .cancel())
//					}
//				} else {
//					NavigationLink(destination: CreateProgramView(), label: {
//						Text(smoker.program.count == 0 ? "Create program".uppercased() : "Edit program".uppercased())
//					})
//					.heading(alignment: .trailing)
//					.frame(maxWidth: .infinity, alignment: .trailing)
//				}
//			}
			
			Spacer()
			
			VStack {
				Text(smoker.statusSummary)
					.font(Font.system(size: 17, weight: .regular, design: .default).smallCaps())
				if smoker.power && !smoker.ready {
					Text("Warming up...")
						.font(Font.system(size: 14, weight: .regular, design: .default).smallCaps())
				}
			}
			.frame(height: 40, alignment: .center)
			
			Spacer()
			
			HStack(alignment: .center, spacing: 0) {
				Spacer()
				
				VStack {
					Button(action: {
						if !smoker.power {
							smoker.power(true)
						} else {
							presentingPowerResetDialog = true
						}
					}) {
						Image(systemName: powerButtonImageIdentifier)
							.font(Font.system(size: buttonSize))
							.accentColor(smoker.power ? .red : .blue)
					}
					.disabled(!smoker.online)
					.frame(height: buttonSize + 10)
					.alert(isPresented: $presentingPowerResetDialog) {
						Alert(title: Text("Confirm"), message: Text("Are you sure you want to shut down?"), primaryButton: .destructive(Text("Shut down")) {
							smoker.power(false)
						}, secondaryButton: .cancel())
					}
					
					Text(smoker.power ? "Shut Down" : "Power On")
						.statusLabel()
						.foregroundColor(smoker.online ? smoker.power ? .red : .primary : .secondary)
				}
				
				Spacer()
				
				VStack {
					Button(action: {
						smoker.runProgram(!smoker.isRunningProgram)
					}) {
						Image(systemName: runButtonImageIdentifier)
							.font(Font.system(size: buttonSize))
							.accentColor(.blue)
					}
					.disabled(smoker.program.count == 0 || !smoker.ready)
					.frame(height: buttonSize + 10)
					.onChange(of: smoker.isRunningProgram) { running in
						if running {
							runButtonImageIdentifier = "pause.fill"
							runButtonString = "Pause"
						} else {
							runButtonImageIdentifier = "play.fill"
							runButtonString = "Start"
						}
					}
					
					Text(runButtonString)
						.statusLabel()
						.foregroundColor(smoker.program.count > 0 && smoker.power ? .primary : .secondary)
				}
				
				Spacer()
				
				VStack {
					Button(action: {
						smoker.keepWarm.toggle()
					}) {
						Image(systemName: "thermometer")
							.font(Font.system(size: buttonSize))
							.accentColor(smoker.keepWarm ? .orange : .blue)
					}
					.disabled(smoker.program.count == 0 || !smoker.isRunningProgram)
					.frame(height: buttonSize + 10)
					.onChange(of: smoker.keepWarm) { enabled in
						if enabled {
							keepWarmButtonString = "Keeping warm"
						} else {
							keepWarmButtonString = "Keep warm"
						}
					}
					
					Text(keepWarmButtonString)
						.statusLabel()
						.foregroundColor(smoker.program.count > 0 && smoker.power ? .primary : .secondary)
				}
				
				Spacer()
			}
			.frame(maxWidth: .infinity, alignment: .center)
			
			Spacer()
		}
		.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
	}
}
