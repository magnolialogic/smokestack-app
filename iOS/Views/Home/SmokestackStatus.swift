/*
 *  SmokestackStatus.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

struct SmokestackStatus: View {
	var body: some View {
		GeometryReader { geometry in
			VStack(alignment: .center, spacing: 0) {
				Spacer()
				
				Status()
					.frame(width: geometry.size.width, height: 240, alignment: .center)
				
				TimerCard()
			}
		}
    }
}

struct SmokestackStatus_Previews: PreviewProvider {
    static var previews: some View {
        SmokestackStatus()
			.previewDisplayName("SmokestackStatus")
    }
}
