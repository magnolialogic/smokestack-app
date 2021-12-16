/*
 *  FooterVieww.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

struct FooterView: View {
    var body: some View {
		Text(verbatim: "smokestack iOS \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0.0.0"))")
			.footer()
    }
}

struct FooterView_Previews: PreviewProvider {
    static var previews: some View {
		FooterView()
			.previewDisplayName("FooterView")
    }
}
