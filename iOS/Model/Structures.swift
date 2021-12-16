/*
 *  Structures.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

// MARK: STRUCTS

struct Credentials {
	let url: String
	let username: String
	let secretKey: String
}

struct CornerRadiusStyle: ViewModifier {
	var radius: CGFloat
	var corners: UIRectCorner
	
	struct CornerRadiusShape: Shape {
		var radius = CGFloat.infinity
		var corners = UIRectCorner.allCorners
		
		func path(in rect: CGRect) -> Path {
			let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
			return Path(path.cgPath)
		}
	}
	
	func body(content: Content) -> some View {
		content
			.clipShape(CornerRadiusShape(radius: radius, corners: corners))
	}
}

// MARK: ENUMS

enum StatusCardType: String {
	case grill = "Grill"
	case probe = "Probe"
}
