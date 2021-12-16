/*
 *  Grabber.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI
import Neumorphic

struct Grabber: View {
    var body: some View {
		Capsule()
			.fill(Color.Neumorphic.darkShadow).softInnerShadow(Capsule(), darkShadow: Color.Neumorphic.darkShadow, lightShadow: Color.Neumorphic.lightShadow, spread: 0.05, radius: 2)
			.frame(width: 64, height: 6, alignment: .center)
			.padding(.top, 8)
			.padding(.bottom, 16)
    }
}

struct Grabber_Previews: PreviewProvider {
    static var previews: some View {
        Grabber()
			.previewDisplayName("Grabber")
    }
}
