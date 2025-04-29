//
//  WebCheckoutView.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 03/03/2025.
//

import Foundation
import SwiftUI
@_implementationOnly import WebKit

struct WebCheckoutView: UIViewRepresentable {
    
    @ObservedObject var viewModel: TransactionViewModel = TransactionViewModel.shared
    @Environment(\.colorScheme) var colorScheme
    
    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        
        // Defines a message handler
        let webPaymentInterface = WebPaymentInterface()
        contentController.add(webPaymentInterface, name: "iOSSDKWebPaymentInterface")
        
        let preferences = WKPreferences()
        preferences.setValue(true, forKey: "developerExtrasEnabled")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        configuration.preferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = "AppCoinsWalletIOS/.."
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.backgroundColor = UIColor(self.colorScheme == .dark ? ColorsUi.APC_WebViewDarkMode : ColorsUi.APC_WebViewLightMode) // or any other UIColor
        webView.isOpaque = false
        if #available(iOS 16.4, *) { webView.isInspectable = true }

        if let URL = viewModel.webCheckout?.URL { webView.load(URLRequest(url: URL)) }
        
        TransactionViewModel.shared.webView = webView
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebCheckoutView
        
        init(_ parent: WebCheckoutView) { self.parent = parent }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) { }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { }
    }
}
