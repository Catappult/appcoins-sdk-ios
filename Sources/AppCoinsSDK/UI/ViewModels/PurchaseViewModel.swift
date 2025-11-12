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
    internal var discountPolicy: DiscountPolicy? = nil
    internal var oemID: String? = nil
    
    internal var webCheckout: WebCheckout? = nil
    @Published internal var webCheckoutType: WebCheckoutType?
    internal var webView: WKWebView? = nil
    
    private init() {}
    
    internal func reset() {
        Utils.log(
            "PurchaseViewModel.reset() at PurchaseViewModel.swift",
            category: "Lifecycle",
            level: .info
        )
        
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
    internal func purchase(
        product: Product,
        domain: String,
        metadata: String?,
        reference: String?,
        discountPolicy: DiscountPolicy? = nil,
        oemID: String? = nil
    ) {
        Utils.log(
            "PurchaseViewModel.purchase(product: \(product), domain: \(domain), metadata: \(metadata), " +
            "reference: \(reference), discountPolicy: \(discountPolicy), oemID: \(oemID) at PurchaseViewModel.swift",
            category: "Lifecycle",
            level: .info
        )
        
        self.product = product
        self.domain = domain
        self.metadata = metadata
        self.reference = reference
        self.discountPolicy = discountPolicy
        self.oemID = oemID
        
        DispatchQueue.main.async {
            Task { @MainActor in
                let guestUID = MMPUseCases.shared.getGuestUID()
                
                self.webCheckout = WebCheckout(
                    domain: domain,
                    product: product.sku,
                    metadata: self.metadata,
                    reference: self.reference,
                    guestUID: guestUID,
                    type: .webview
                )
                
                self.hasActivePurchase = true
                self.webCheckoutType = .webview
            }
        }
    }
    
    // Handles the dismiss (click on the zone above the bottom sheet) for the multiple states of the bottom sheet
    internal func dismiss() {
        Utils.log(
            "PurchaseViewModel.dismiss() at PurchaseViewModel.swift",
            category: "Lifecycle",
            level: .info
        )
        
        self.cancel()
    }
    
    // Dismiss Bottom Sheet
    private func dismissVC(completion: @escaping () -> Void) {
        Utils.log(
            "PurchaseViewModel.dismissVC() at PurchaseViewModel.swift",
            category: "Lifecycle",
            level: .info
        )
        
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
        Utils.log(
            "PurchaseViewModel.cancel() at PurchaseViewModel.swift",
            category: "Lifecycle",
            level: .info
        )
        
        self.dismissVC {
            let result : PurchaseResult = .userCancelled
            self.sendResult(result: result)
            
            // Clear data related to finished purchase
            self.reset()
        }
    }
    
    internal func failed(error: AppCoinsSDKError) {
        Utils.log(
            "PurchaseViewModel.failed() at PurchaseViewModel.swift",
            category: "Lifecycle",
            level: .info
        )
        
        self.dismissVC {
            let result: PurchaseResult = .failed(error: error)
            self.sendResult(result: result)
            
            // Clear data related to finished purchase
            self.reset()
        }
    }
    
    internal func success(verificationResult: VerificationResult) {
        Utils.log(
            "PurchaseViewModel.success(verificationResult: \(verificationResult)) at PurchaseViewModel.swift",
            category: "Lifecycle",
            level: .info
        )
        
        self.dismissVC {
            let result: PurchaseResult = .success(verificationResult: verificationResult)
            self.sendResult(result: result)
            
            // Clear data related to finished purchase
            self.reset()
        }
    }
    
    internal func sendResult(result: PurchaseResult) {
        Utils.log(
            "PurchaseViewModel.sendResult(result: \(result)) at PurchaseViewModel.swift",
            category: "Lifecycle",
            level: .info
        )
        
        NotificationCenter.default.post(name: NSNotification.Name("APPCPurchaseResult"), object: nil, userInfo: ["PurchaseResult" : result])
    }
    
    internal func setOrientation(orientation: Orientation) { self.orientation = orientation }
    
    internal func handleCheckoutSuccessDeeplink(deeplink: URL) {
        Utils.log(
            "PurchaseViewModel.handleCheckoutSuccessDeeplink(deeplink: \(deeplink)) at PurchaseViewModel.swift",
            category: "Lifecycle",
            level: .info
        )
        
        do {
            let query = try OnPurchaseResultQuery(deeplink: deeplink)
            OnPurchaseResult.shared.handle(query: query)
        } catch {
            if let error = error as? AppCoinsSDKError { Utils.log(error.description) }
        }
    }
    
    internal func handleCheckoutFailureDeeplink(deeplink: URL) {
        Utils.log(
            "PurchaseViewModel.handleCheckoutFailureDeeplink(deeplink: \(deeplink)) at PurchaseViewModel.swift",
            category: "Lifecycle",
            level: .info
        )
        
        do {
            let query = try OnErrorQuery(deeplink: deeplink)
            OnError.shared.handle(query: query)
        } catch {
            if let error = error as? AppCoinsSDKError {
                Utils.log(
                    "Checkout deeplink handling failed with error: \(error.description) " +
                          "at PurchaseViewModel.swift.handleCheckoutFailureDeeplink",
                    level: .error
                )
            }
        }
    }
    
    internal func handleWebViewDeeplink(deeplink: String) {
        Utils.log(
            "PurchaseViewModel.handleWebViewDeeplink(deeplink: \(deeplink)) at PurchaseViewModel.swift",
            category: "Lifecycle",
            level: .info
        )
        
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
                Utils.log("Error sending message to WebView: \(error.localizedDescription)", level: .error)
            } else {
                Utils.log("Called window.handleIOSRedirect('\(finalURL)') successfully")
            }
        }
    }
    
}
