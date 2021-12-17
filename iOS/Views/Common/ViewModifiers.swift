/*
 *  ViewModifiers.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI
import CoreSmokestack

struct Heading: ViewModifier {
	var alignment: Alignment
	
	func body(content: Content) -> some View {
		content
			.font(.system(size: 12, weight: .bold, design: .default))
	}
}

struct Footer: ViewModifier {
	func body(content: Content) -> some View {
		content
			.frame(maxWidth: .infinity, alignment: .center)
			.padding(.top, 40)
			.padding(.bottom, 25)
			.font(.system(size: 10, weight: .light))
			.foregroundColor(Color.Neumorphic.secondary)
	}
}

struct temperatureKeyViewModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.system(size: 12, weight: .regular, design: .default))
	}
}

struct temperatureValueViewModifier: ViewModifier {
	let type: SmokeSensorKey
	
	func body(content: Content) -> some View {
		content
			.font(.system(size: type.rawValue.contains("Current") ? CGFloat(48) : CGFloat(24), weight: type.rawValue.contains("Current") ? .regular : .light, design: .default))
	}
}

struct ClearButton: ViewModifier {
	@Binding var text: String
	
	public func body(content: Content) -> some View {
		HStack(alignment: .center) {
			content
			
			if !text.isEmpty {
				Button(action: {
					self.text = ""
				}, label: {
					Image(systemName: "xmark.circle.fill")
						.foregroundColor(Color.Neumorphic.secondary)
				})
			}
		}
	}
}
