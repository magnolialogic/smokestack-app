/*
 *  SmokestackToolbox.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

final class SmokestackToolbox {
	private init() {}
	static let shared = SmokestackToolbox()
	
	let feedbackGenerator = UIImpactFeedbackGenerator()
	let jsonEncoder = JSONEncoder()
	let jsonDecoder = JSONDecoder()
}
