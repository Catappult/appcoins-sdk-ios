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
        Utils.log("Method: \(method)")
        
        // Parse Params
        guard let paramsDict = body["params"] as? [String: Any],
              let params = try? JSONSerialization.data(withJSONObject: paramsDict, options: []) else {
            Utils.log("Failed to parse message params")
            return
        }
        Utils.log("Params: \(params)")
        
        switch method {
        case .onPurchaseResult: 
            do {
                let onPurchaseResultBody = try JSONDecoder().decode(OnPurchaseResultBody.self, from: params)
                OnPurchaseResult.handle(body: onPurchaseResultBody)
            } catch {
                Utils.log("Failed to parse onPurchaseResult body with error: \(error)")
                return
            }
        case .onError: 
            do {
                let onErrorBody = try JSONDecoder().decode(OnErrorBody.self, from: params)
                OnError.handle(body: onErrorBody)
            } catch {
                Utils.log("Failed to parse onError body with error: \(error)")
                return
            }
        }
    }
}
