/*
 *  StarscreamClient.swift
 *  https://github.com/magnolialogic/smokestack-app
 *
 *  © 2021-Present @magnolialogic
 */

import Foundation
import SwiftUI
import Starscream
import MLCommon
import CoreSmokestack

class StarscreamClient: WebSocketDelegate {
	var connected = false {
		didSet {
			MLLogger.console(String(describing: connected))
		}
	}
	
	var socket: WebSocket?
	
	func connect() {
		let requestURL = URL(string: VaporClient.shared.url.replacingOccurrences(of: "http", with: "ws") + "/api/client/ws")!
		MLLogger.console(String(describing: requestURL))
		var wsRequest = URLRequest(url: requestURL)
		wsRequest.setBasicAuth(username: "app", password: VaporClient.shared.secretKey)
		wsRequest.timeoutInterval = 30
		self.socket = WebSocket(request: wsRequest)
		self.socket?.delegate = self
		socket?.connect()
	}
	
	func didReceive(event: WebSocketEvent, client: WebSocketClient) {
		switch event {
		case .connected(_):
			self.connected = true
		case .cancelled:
			MLLogger.console("cancelled")
			self.connected = false
		case .disconnected(let reason, let code):
			MLLogger.console("disconnected \(reason) with code \(code)")
			self.connected = false
		case .binary(let data):
			do {
				let smokeReport = try SmokestackToolbox.shared.jsonDecoder.decode(SmokeReport.self, from: data)
				VaporClient.shared.handleSmokeReport(smokeReport)
			} catch {
				MLLogger.error("binary data does not conform to WebSocketReport.self")
			}
		case .viabilityChanged(let viability):
			MLLogger.debug("viable: \(String(describing: viability))")
		case .reconnectSuggested(let suggestion):
			MLLogger.console("reconnect suggested \(String(describing: suggestion))")
		case .error(let error):
			self.connected = false
			var message: String
			if let e = error as? WSError {
				message = e.message
			} else if let e = error {
				message = e.localizedDescription
			} else {
				message = "unhandled error"
			}
			MLLogger.error(message)
		default: // .ping(_), .pong(_), .text(_)
			break
		}
	}
}
