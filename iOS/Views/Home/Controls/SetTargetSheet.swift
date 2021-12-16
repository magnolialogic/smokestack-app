//
//  SetTargetSheet.swift
//  smokestack
//
//  Created by Chris Coffin on 12/14/21.
//

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
