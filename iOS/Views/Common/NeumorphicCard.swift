/*
 *  NeumorphicCard.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI
import Neumorphic

struct NeumorphicCard<Content: View>: View {
	let content: Content
	let cornerRadius: CGFloat
	
	init(cornerRadius: CGFloat = 24, @ViewBuilder content: @escaping () -> Content) {
		self.cornerRadius = cornerRadius
		self.content = content()
	}
	
    var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .center) {
				RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
					.fill(Color.Neumorphic.main).softOuterShadow()
				
				content
			}
		}
    }
}

struct NeumorphicCard_Previews: PreviewProvider {
    static var previews: some View {
		GeometryReader { geometry in
			NeumorphicCard() {
				Text("NeumorphicCard")
			}
		}
    }
}
