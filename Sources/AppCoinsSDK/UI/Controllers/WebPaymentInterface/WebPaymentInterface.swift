//
//  WebPaymentInterface.swift
//
//
//  Created by aptoide on 04/04/2025.
//

import SwiftUI
import UIKit
@_implementationOnly import WebKit

internal class WebPaymentInterface: NSObject, WKScriptMessageHandler {
    
    // Handle JavaScript Messages
    internal func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        Utils.log("SDK received message for name: \(message.name)")
        guard message.name == "iOSSDKWebPaymentInterface" else { return } // Unknown Handler
        Utils.log("SDK received message with body: \(message.body)")
        guard let body = message.body as? [String: Any] else { return } // No Message Body
        
        // Parse Method
        guard let methodName = body["method"] as? String,
              let method = WebPaymentInterfaceMethod(rawValue: methodName) else {
            Utils.log("Failed to parse message method")
            return
        }
        
        // Parse Params
        guard let paramsDict = body["params"] as? [String: Any],
              let params = try? JSONSerialization.data(withJSONObject: paramsDict, options: []) else {
            Utils.log("Failed to parse message params")
            return
        }
        
        switch method {
        case .onPurchaseResult: 
            do {
                let onPurchaseResultBody = try JSONDecoder().decode(OnPurchaseResultBody.self, from: params)
                OnPurchaseResult.shared.handle(body: onPurchaseResultBody)
            } catch {
                Utils.log("Failed to parse onPurchaseResult body with error: \(error)")
                return
            }
        case .onError: 
            do {
                let onErrorBody = try JSONDecoder().decode(OnErrorBody.self, from: params)
                OnError.shared.handle(body: onErrorBody)
            } catch {
                Utils.log("Failed to parse onError body with error: \(error)")
                return
            }
        case .handleAuthenticationRedirect:
            do {
                let handleAuthenticationRedirectBody = try JSONDecoder().decode(HandleAuthenticationRedirectBody.self, from: params)
                HandleAuthenticationRedirect.shared.handle(body: handleAuthenticationRedirectBody)
            } catch {
                Utils.log("Failed to parse handleAuthenticationRedirect body with error: \(error)")
                return
            }
        case .handleExternalRedirect:
            do {
                let handleExternalRedirectBody = try JSONDecoder().decode(HandleExternalRedirectBody.self, from: params)
                HandleExternalRedirect.shared.handle(body: handleExternalRedirectBody)
            } catch {
                Utils.log("Failed to parse handleExternalRedirect body with error: \(error)")
                return
            }
        case .setActiveWallet:
            do {
                let setActiveWalletBody = try JSONDecoder().decode(SetActiveWalletBody.self, from: params)
                SetActiveWallet.shared.handle(body: setActiveWalletBody)
            } catch {
                Utils.log("Failed to parse setActiveWallet body body with error: \(error)")
                return
            }
        }
    }
}
