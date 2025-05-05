//
//  TransactionViewModel.swift
//
//
//  Created by aptoide on 19/10/2023.
//

import Foundation
@_implementationOnly import WebKit

// Helper to the BottomSheetViewModel
internal class TransactionViewModel: ObservableObject {
    
    internal static var shared: TransactionViewModel = TransactionViewModel()
    
    @Published internal var hasActiveTransaction = false
    
    // Device Orientation
    @Published internal var orientation: Orientation = .portrait
    
    // Transaction attributes
    internal var product: Product? = nil
    internal var domain: String? = nil
    internal var metadata: String? = nil
    internal var reference: String? = nil
    
    internal var webCheckout: WebCheckout? = nil
    internal var webView: WKWebView? = nil
    
    private init() {}
    
    internal func reset() {
        self.hasActiveTransaction = false
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
            let guestUID = MMPUseCases.shared.getGuestUID()
            
            // 1. Build the Web Checkout to process the transaction
            self.webCheckout = WebCheckout(domain: domain, product: product.sku, metadata: self.metadata, reference: self.reference, guestUID: guestUID)
            
            // 2. Show loaded view
            self.hasActiveTransaction = true
        }
    }
    
    // Handles the dismiss (click on the zone above the bottom sheet) for the multiple states of the bottom sheet
    internal func dismiss() {
        self.cancel()
    }
    
    // Dismiss Bottom Sheet
    private func dismissVC() {
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController,
           let presentedPurchaseVC = rootViewController.presentedViewController as? PurchaseViewController {
            
            var delay = 0.3
            if KeyboardObserver.shared.isKeyboardVisible { delay = 0.45 }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                presentedPurchaseVC.dismissPurchase()
                self.hasActiveTransaction = false
            }
        }
        
        self.reset() // Clear data related to finished purchase
    }
    
    internal func cancel() {
        let result : TransactionResult = .userCancelled
        TransactionViewModel.shared.sendResult(result: result)
        self.dismissVC()
    }
    
    internal func failed(error: AppCoinsSDKError, description: String? = nil) {
        switch error {
        case .networkError:
            let result: TransactionResult = .failed(error: error)
            self.sendResult(result: result)
            DispatchQueue.main.async { self.hasActiveTransaction = false }
        default:
            let result: TransactionResult = .failed(error: error)
            self.sendResult(result: result)
            DispatchQueue.main.async { self.hasActiveTransaction = false }
        }
    }
    
    internal func sendResult(result: TransactionResult) {
        NotificationCenter.default.post(name: NSNotification.Name("APPCPurchaseResult"), object: nil, userInfo: ["TransactionResult" : result])
    }
    
    internal func setOrientation(orientation: Orientation) { self.orientation = orientation }
    
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
