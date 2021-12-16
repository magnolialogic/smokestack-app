/*
 *  LoginView.swift
 *  https://github.com/magnolialogic/swiftui-smokestack_app
 *
 *  © 2021-Present @magnolialogic
 */

import SwiftUI
import Neumorphic

struct LoginView: View {
	enum Field: Hashable {
		case url
		case secretKey
	}
	
	@EnvironmentObject var flags: SmokestackFlags
	@EnvironmentObject var vapor: VaporClient
	@EnvironmentObject var smoker: SmokerClient
	@State var failedRequest = false
	@State var url: String = ""
	@State var secretKey: String = ""
	@FocusState private var focus: Field?
	
	var body: some View {
		GeometryReader { geometry in
			if flags.setupInProgress {
				VStack(alignment: .center) {
					Spacer()
					
					ProgressView()
						.scaleEffect(2.5, anchor: .center)
						.padding(.bottom, 15)
					
					Text("Connecting")
						.font(Font.footnote.smallCaps())
						.padding(.top, 25)
						.padding(.bottom, 5)
					
					Button(action: {
						vapor.finishSetup(false)
					}, label: {
						Text("Cancel")
							.foregroundColor(.red)
							.fontWeight(.heavy)
					})
					
					Spacer()
				}
				.frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
				.background(Color.Neumorphic.main)
			} else { // !setupInProgress
				let screenWidth = geometry.size.width
				let inset = screenWidth / 6
				
				VStack(alignment: .center) {
					VStack(alignment: .center) {
						VStack(alignment: .leading, spacing: 0) {
							Text("smokestack server")
								.font(Font.headline.smallCaps())
								.foregroundColor(Color.Neumorphic.secondary)
								.padding(.bottom, 0)
							
							Divider()
								.padding(.top, 0)
						}
						.frame(width: screenWidth, height: 80, alignment: .bottomLeading)
						.padding(EdgeInsets(top: 0, leading: 40, bottom: 20, trailing: 0))
						
						HStack(alignment: .lastTextBaseline) {
							Text("URL:")
								.font(Font.callout.smallCaps())
								.frame(width: inset, alignment: .trailing)
							
							VStack(spacing: 0) {
								TextField("address", text: $url)
									.keyboardType(.URL)
									.autocapitalization(.none)
									.disableAutocorrection(true)
									.modifier(ClearButton(text: $url))
									.focused($focus, equals: .url)
									.submitLabel(.next)
									.onSubmit {
										focus = .secretKey
									}
								
								Divider()
									.padding(.top, 0)
							}
							.frame(maxWidth: .infinity)
							
							Spacer()
								.frame(width: 10)
						}
						.frame(width: screenWidth, height: 20)
						.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
						
						HStack(alignment: .lastTextBaseline) {
							Text("Key:")
								.font(Font.callout.smallCaps())
								.frame(width: inset, alignment: .trailing)
							
							VStack(spacing: 0) {
								SecureField("secret key", text: $secretKey)
									.modifier(ClearButton(text: $secretKey))
									.focused($focus, equals: .secretKey)
									.onSubmit {
										focus = .none
									}
								
								Divider()
									.padding(.top, 0)
							}
							.frame(maxWidth: .infinity)
							
							Spacer()
								.frame(width: 10)
						}
						.frame(width: screenWidth, height: 20)
						.padding(EdgeInsets(top: 0, leading: 20, bottom: 40, trailing: 20))
					}
					
					VStack {
						Text("Request failed")
							.font(Font.callout.smallCaps())
							.fontWeight(.semibold)
						Text("Bad URL or secret key")
							.font(Font.footnote.lowercaseSmallCaps())
							.fontWeight(.light)
					}
					.foregroundColor(.red)
					.padding(.bottom, 40)
					.hidden(!failedRequest)
					.onChange(of: focus) { newFocus in
						if failedRequest && newFocus != .none {
							failedRequest = false
						}
					}
					
					Button(action: {
						flags.setupInProgress = true
						Task {
							try await vapor.httpRegisterClient(true, server: url, secretKey: secretKey)
							if flags.setupDone {
								failedRequest = false
								flags.presentDrawer = false
							} else {
								failedRequest = true
								url = ""
								secretKey = ""
							}
						}
					}, label: {
						Text("Connect")
							.foregroundColor(!url.isValidURL || secretKey.count < 8 || !flags.networkReachable ? Color(UIColor.lightGray) : Color.blue)
							.fontWeight(.heavy)
							.padding(.vertical, 10)
							.frame(width: 150)
					})
					.softButtonStyle(Capsule(), padding: 10, pressedEffect: .hard)
					.disabled(!url.isValidURL || secretKey.count < 8 || !flags.networkReachable || flags.setupInProgress)
					
					Spacer()
					
					FooterView()
				}
				.frame(width: screenWidth)
			}
		}
	}
}

struct LoginView_Previews: PreviewProvider {
	static var previews: some View {
		LoginView()
			.previewDisplayName("LoginView")
	}
}
