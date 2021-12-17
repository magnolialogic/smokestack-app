/*
 *  Flags.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import Foundation
import SwiftUI
import MLCommon
import CoreSmokestack

final class SmokestackFlags: ObservableObject {
	private init() {}
	static let shared = SmokestackFlags()
	
	// MARK: Connectivity
	
	@Published var networkReachable = false {
		willSet {
			if newValue != networkReachable {
				MLLogger.debug(String(describing: newValue))
			}
		}
		didSet {
			if !networkReachable && connected {
				connected = false
			}
			if networkReachable && setupDone && !connected {
				Task {
					try await VaporClient.shared.httpRegisterClient(true, server: VaporClient.shared.url, secretKey: VaporClient.shared.secretKey)
				}
			}
		}
	}
	
	@Published var connected = false {
		didSet {
			MLLogger.console(String(describing: connected))
			if connected && !VaporClient.shared.webSocket.connected {
				VaporClient.shared.webSocket.connect()
			} else {
				SmokerClient.shared.state.online = false
				VaporClient.shared.webSocket.socket?.disconnect()
			}
		}
	}
	
	// MARK: Smoker
	
	@Published var runningProgram = false {
		didSet {
			MLLogger.debug(String(describing: runningProgram))
		}
	}
	
	@Published var useCelsius = UserDefaults.standard.integer(forKey: "useCelsius") {
		didSet {
			MLLogger.console(String(describing: useCelsius.bool()))
			UserDefaults.standard.setValue(useCelsius, forKey: "useCelsius")
		}
	}
	
	@Published var customProgram = 0
	
	// MARK: View lifecycle
	
	@Published var presentDrawer = false {
		didSet {
			MLLogger.debug(String(describing: presentDrawer))
		}
	}
	
	@Published var presentSetTargetChoiceDialog = false {
		didSet {
			MLLogger.debug(String(describing: presentSetTargetChoiceDialog))
		}
	}
	
	@Published var presentPresetTemperatureChoiceDialog = false {
		didSet {
			MLLogger.debug(String(describing: presentPresetTemperatureChoiceDialog))
		}
	}
	
	@Published var presentPresetTimeChoiceDialog = false {
		didSet {
			MLLogger.debug(String(describing: presentPresetTimeChoiceDialog))
		}
	}
	
	@Published var presentCustomProgramSheet = false {
		didSet {
			MLLogger.debug(String(describing: presentCustomProgramSheet))
		}
	}
	
	@Published var presentDisconnectConfirmationDialog = false {
		didSet {
			MLLogger.debug(String(describing: presentDisconnectConfirmationDialog))
		}
	}
	
	@Published var presentShutdownConfirmationDialog = false {
		didSet {
			MLLogger.debug(String(describing: presentShutdownConfirmationDialog))
		}
	}
	
	@Published var apnsRegistrationSuccess = false {
		didSet {
			MLLogger.debug(String(describing: apnsRegistrationSuccess))
		}
	}
	
	@Published var setupInProgress = false {
		didSet {
			MLLogger.debug(String(describing: setupInProgress))
		}
	}
	
	@Published var setupDone = UserDefaults.standard.bool(forKey: "setupDone") {
		didSet {
			MLLogger.debug(String(describing: setupDone))
			UserDefaults.standard.setValue(setupDone, forKey: "setupDone")
			if !setupDone && connected {
				connected = false
			}
		}
	}
	
	@Published var SIWASetupDone = UserDefaults.standard.bool(forKey: "SIWASetupDone") {
		didSet {
			MLLogger.debug(String(describing: SIWASetupDone))
			UserDefaults.standard.setValue(SIWASetupDone, forKey: "SIWASetupDone")
			if SIWASetupDone {
				SmokestackPermissions.shared.getNotificationAuthorizationStatus()
			}
		}
	}
	
}
