/*
 *  Smoker.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
 */


import SwiftUI
import Combine
import MLCommon
import CoreSmokestack

final class SmokerClient: ObservableObject {
	var anyCancellable: AnyCancellable? = nil
	
	private init() { // Percolate objectWillChange notifications from state -> SmokerClient
		anyCancellable = state.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] (_) in
			self?.objectWillChange.send()
		}
	}
	
	static let shared = SmokerClient()	
	
	@Published var state = SmokeState.shared
	
	var program: SmokeProgram? {
		didSet {
			MLLogger.debug(program.debugDescription)
		}
	}
	
	@Published var summary: String = "Idle" {
		didSet {
			MLLogger.debug(summary)
		}
	}
	
	@Published var version = "Unknown" {
		didSet {
			MLLogger.console(version)
		}
	}
	
	func setPower(_ run: Bool) {
		MLLogger.console(String(describing: run))
		VaporClient.shared.setPower(run)
	}
	
	func addNewProgram(mode: SmokeMode, trigger: SmokeStep.Trigger, limit: Int, targetGrill: Measurement<UnitTemperature>) {
		var steps: [SmokeStep] = []
		let targetGrillInt = Int(targetGrill.value)
		steps.append(SmokeStep(mode: .start, trigger: .time, limit: 900, targetGrill: 150))
		steps.append(SmokeStep(mode: mode, trigger: trigger, limit: limit, targetGrill: targetGrillInt))
		let program = SmokeProgram(steps: steps)
		self.program = program
	}
	
	func getLocalizedTemperature(for sensor: SmokeSensorKey) -> Double? {
		var temperature: Measurement<UnitTemperature>?
		switch sensor {
		case .grillCurrent:
			temperature = state.temps[.grillCurrent]
		case .grillTarget:
			temperature = state.temps[.grillTarget]
		case .probeCurrent:
			temperature = state.temps[.probeCurrent]
		case .probeTarget:
			temperature = state.temps[.probeCurrent]
		}
		
		let localizedDoubleTemperature = temperature?.converted(to: SmokestackFlags.shared.useCelsius != 0 ? UnitTemperature.celsius : UnitTemperature.fahrenheit).value
		
		return localizedDoubleTemperature
	}
}
