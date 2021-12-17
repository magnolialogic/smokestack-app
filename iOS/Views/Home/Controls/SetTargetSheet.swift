/*
 *  SetTargetSheet
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI

struct SetTargetSheet: View {
	@State var useProgram = 0
	
    var body: some View {
		GeometryReader { geometry in
			VStack(alignment: .center) {
				Grabber()
				
				Spacer()
				
			}.frame(width: geometry.size.width)
		}
    }
}

struct SetTargetSheet_Previews: PreviewProvider {
    static var previews: some View {
        SetTargetSheet()
    }
}
