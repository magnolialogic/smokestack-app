/*
 *  FrontPorch.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
 */

import AuthenticationServices
import Combine
import SwiftUI
import MLCommon
import CoreSmokestack

struct FrontPorch: View {
	@EnvironmentObject var flags: SmokestackFlags
	@EnvironmentObject var vapor: VaporClient
	
	var body: some View {
		GeometryReader { geometry in
			VStack(alignment: .center) {
				Spacer()
				
				Image("smokestackTransparent")
				
				Spacer()
				
				SignInWithAppleButton(
					.signIn,
					onRequest: { request in
						request.requestedScopes = []
					},
					onCompletion: { result in
						switch result {
						case .success (let authResults):
							let authCredential = authResults.credential as! ASAuthorizationAppleIDCredential
							let authCredentialUserID = authCredential.user
							vapor.userID = authCredentialUserID.data(using: .utf8)!.base64EncodedString()
							DispatchQueue.main.async {
								flags.SIWASetupDone = true
								triggerLocalNetworkPrivacyAlert() // Do this here to try and prevent it happening when we make our first network call
							}
						case.failure (let error):
							MLLogger.error(error.localizedDescription)
							DispatchQueue.main.async {
								flags.SIWASetupDone = false
							}
						}
					}
				)
				.frame(width: 280, height: 60, alignment: .center)
				
				Spacer()
			}
			.frame(width: geometry.size.width)
		}
	}
}

struct FrontPorch_Previews: PreviewProvider {
    static var previews: some View {
        FrontPorch()
			.previewDisplayName("FrontPorch")
    }
}
