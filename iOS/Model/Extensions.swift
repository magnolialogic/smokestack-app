/*
 *  Extensions.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import Foundation
import Combine
import SwiftUI
import CoreSmokestack

// MARK: CoreSmokestack

extension SmokeState: ObservableObject {}

// MARK: OBSERVABLEOBJECT

extension ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
	func subscribe<T: ObservableObject>(
		_ observableObject: T
	) -> AnyCancellable where T.ObjectWillChangePublisher == ObservableObjectPublisher {
		return objectWillChange
			.receive(on: DispatchQueue.main) // Publishing changes from background threads is not allowed
			.sink { [weak observableObject] (_) in
				observableObject?.objectWillChange.send()
			}
	}
}


// MARK: BINDING

extension Binding {
	
	// https://stackoverflow.com/a/60130311/15166838
	//
	// This BS is necessary since View's native onChange method
	// doesn't fire the first time the underlying @State changes
	func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
		return Binding(get: {
			self.wrappedValue
		}, set: { selection in
			self.wrappedValue = selection
			handler(selection)
		})
	}
}

// MARK: VIEW

extension View {
	@ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
		if shouldHide { hidden() }
		else { self }
	}
}

extension View {
	func heading(alignment: Alignment) -> some View {
		self.modifier(Heading(alignment: alignment))
	}
	
	func footer() -> some View {
		self.modifier(Footer())
	}
	
	func temperatureKey() -> some View {
		self.modifier(temperatureKeyViewModifier())
	}
	
	func temperatureValue(type: SmokeSensorKey) -> some View {
		self.modifier(temperatureValueViewModifier(type: type))
	}
}

extension View {
	func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
		ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
	}
}

// MARK: COLOR

extension LinearGradient {
	static var nominalThermometer: LinearGradient {
		return LinearGradient(colors: [.yellow, .orange, Color("thermometerRed")], startPoint: .bottom, endPoint: .top)
	}
	
	static var happyThermometer: LinearGradient {
		return LinearGradient(colors: [.green], startPoint: .bottom, endPoint: .top)
	}
	
	static var overTempThermometer: LinearGradient {
		return LinearGradient(colors: [.red], startPoint: .bottom, endPoint: .top)
	}
}

// MARK: DOUBLE

extension Double {
	var stringDescribing: String {
		return String(format: "%.1f", self)
	}
}

// MARK: FOUNDATION

extension UIApplication {
	static var appVersion: String? {
		return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
	}
}

extension UserDefaults {
	func valueExists(forKey key: String) -> Bool {
		return object(forKey: key) != nil
	}
}

extension URLRequest {
	mutating func setBasicAuth(username: String, password: String) {
		let encodedAuthInfo = "\(username):\(password)"
			.data(using: .utf8)!
			.base64EncodedString()
		addValue("Basic \(encodedAuthInfo)", forHTTPHeaderField: "Authorization")
	}
	
	mutating func setContentType(_ contentType: String) {
		addValue(contentType, forHTTPHeaderField: "content-type")
	}
}
