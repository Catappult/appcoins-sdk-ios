//
//  PurchaseViewModel.swift
//
//
//  Created by aptoide on 19/10/2023.
//

import Foundation
import UIKit
@_implementationOnly import WebKit

internal class PurchaseViewModel: ObservableObject {
    
    internal static var shared: PurchaseViewModel = PurchaseViewModel()
    
    // Device Orientation
    @Published internal var orientation: Orientation = .portrait
    
    @Published internal var hasActivePurchase = false
    
    // Transaction attributes
    internal var product: Product? = nil
    internal var domain: String? = nil
    internal var metadata: String? = nil
    internal var reference: String? = nil
    
    internal var webCheckout: WebCheckout? = nil
    @Published internal var webCheckoutType: WebCheckoutType?
    internal var webView: WKWebView? = nil
    
    private init() {}
    
    internal func reset() {
        self.hasActivePurchase = false
        self.webCheckoutType = nil
        self.product = nil
        self.domain = nil
        self.metadata = nil
        self.reference = nil
        self.webCheckout = nil
        self.webView = nil
    }
    
    // Called when a user starts a product purchase
    internal func purchase(product: Product, domain: String, metadata: String?, reference: String?) {
        self.product = product
        self.domain = domain
        self.metadata = metadata
        self.reference = reference
        
        DispatchQueue.main.async {
            Task { @MainActor in
                let guestUID = MMPUseCases.shared.getGuestUID()
                
                if await AppcSDK.isAvailableInUS() {
                    self.webCheckout = WebCheckout(domain: domain, product: product.sku, metadata: self.metadata, reference: self.reference, guestUID: guestUID, type: .browser)
                    
                    guard let checkoutURL: URL = self.webCheckout?.URL else {
                        self.failed(error: .systemError(message: "Web Checkout URL is invalid", description: "Could not open Browser Web Checkout because URL is invalid at PurchaseViewModel.swift:purchase"))
                        return
                    }
                    
                    UIApplication.shared.open(checkoutURL, options: [:]) { _ in
                        self.hasActivePurchase = true
                        self.webCheckoutType = .browser
                    }
                } else {
                    self.webCheckout = WebCheckout(domain: domain, product: product.sku, metadata: self.metadata, reference: self.reference, guestUID: guestUID, type: .webview)
                    
                    self.hasActivePurchase = true
                    self.webCheckoutType = .webview
                }
            }
        }
    }
    
    // Handles the dismiss (click on the zone above the bottom sheet) for the multiple states of the bottom sheet
    internal func dismiss() {
        self.cancel()
    }
    
    // Dismiss Bottom Sheet
    private func dismissVC(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController,
               let presentedPurchaseVC = rootViewController.presentedViewController as? PurchaseViewController {
                
                var delay = 0.0
                if KeyboardObserver.shared.isKeyboardVisible { delay = 0.15 }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    presentedPurchaseVC.dismissPurchase(animated: self.webCheckoutType != .browser, completion: completion)
                }
            }
        }
    }
    
    internal func cancel() {
        self.dismissVC {
            let result : PurchaseResult = .userCancelled
            self.sendResult(result: result)
            
            // Clear data related to finished purchase
            self.reset()
        }
    }
    
    internal func failed(error: AppCoinsSDKError) {
        self.dismissVC {
            let result: PurchaseResult = .failed(error: error)
            self.sendResult(result: result)
            
            // Clear data related to finished purchase
            self.reset()
        }
    }
    
    internal func success(verificationResult: VerificationResult) {
        self.dismissVC {
            let result: PurchaseResult = .success(verificationResult: verificationResult)
            self.sendResult(result: result)
            
            // Clear data related to finished purchase
            self.reset()
        }
    }
    
    internal func sendResult(result: PurchaseResult) {
        NotificationCenter.default.post(name: NSNotification.Name("APPCPurchaseResult"), object: nil, userInfo: ["PurchaseResult" : result])
    }
    
    internal func setOrientation(orientation: Orientation) { self.orientation = orientation }
    
    internal func handleCheckoutSuccessDeeplink(deeplink: URL) {
        do {
            let query = try OnPurchaseResultQuery(deeplink: deeplink)
            OnPurchaseResult.shared.handle(query: query)
        } catch {
            if let error = error as? AppCoinsSDKError { Utils.log(error.description) }
        }
    }
    
    internal func handleCheckoutFailureDeeplink(deeplink: URL) {
        do {
            let query = try OnErrorQuery(deeplink: deeplink)
            OnError.shared.handle(query: query)
        } catch {
            if let error = error as? AppCoinsSDKError { Utils.log(error.description) }
        }
    }
    
    internal func handleWebViewDeeplink(deeplink: String) {
        guard let webView = webView else {
            Utils.log("WebView is not defined on authentication redirect")
            return
        }
        
        guard var components = URLComponents(string: deeplink) else {
            Utils.log("Not a valid URL")
            return
        }
        
        components.scheme = nil
        guard let trimmedURL = components.string else {
            Utils.log("Failed to trim scheme from URL")
            return
        }
        
        let trimmedPrefixURL = trimmedURL.hasPrefix("//") ? String(trimmedURL.dropFirst(2)) : trimmedURL
        let finalURL = trimmedPrefixURL.hasSuffix("#") ? String(trimmedPrefixURL.dropLast(1)) : trimmedPrefixURL
        
        webView.evaluateJavaScript("window.handleIOSRedirect('\(finalURL)')") { result, error in
            if let error = error {
                Utils.log("Error sending message to WebView: \(error.localizedDescription)")
            } else {
                Utils.log("Called window.handleIOSRedirect('\(finalURL)') successfully")
            }
        }
    }
    
}
