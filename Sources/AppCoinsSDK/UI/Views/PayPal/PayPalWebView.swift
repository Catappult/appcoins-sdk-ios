//
//  PayPalWebView.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import SwiftUI
@_implementationOnly import WebKit

internal struct PayPalWebView: UIViewRepresentable {
    internal var url: URL
    internal var method: String
    internal var successHandler: (_ token: String) -> Void
    internal var cancelHandler: (_ token: String?) -> Void
    
    internal func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView
        
        var request = URLRequest(url: url)
        request.httpMethod = method

        webView.load(request)
        return webView
    }

    internal func updateUIView(_ uiView: WKWebView, context: Context) {}

    internal func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    internal class Coordinator: NSObject, WKNavigationDelegate {
        internal let parent: PayPalWebView
        internal var webView: WKWebView?

        internal init(parent: PayPalWebView) {
            self.parent = parent
        }

        internal func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // The web page finished loading
        }

        internal func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            let successURL = BuildConfiguration.billingServiceURL + "/gateways/paypal/billing-agreement/token/return/success"
            let cancelURL = BuildConfiguration.billingServiceURL + "/gateways/paypal/billing-agreement/token/return/cancel"
            
            if let url = navigationAction.request.url?.absoluteString {
                if var urlComponents = URLComponents(string: url) {
                    let query = urlComponents.queryItems
                    urlComponents.query = nil
                    let path = urlComponents.string
                    if let token = query?.first(where: { $0.name == "token" })?.value, let tokenBA = query?.first(where: { $0.name == "ba_token" })?.value {
                        if path == successURL {
                            // Handle success
                            self.parent.successHandler(tokenBA)
                            decisionHandler(.cancel)
                        } else if path == cancelURL {
                            // Handle cancel
                            self.parent.cancelHandler(tokenBA)
                            decisionHandler(.cancel)
                        } else {
                            decisionHandler(.allow)
                        }
                    } else {
                        decisionHandler(.allow)
                    }
                } else { decisionHandler(.allow) }
            } else { decisionHandler(.allow) }
        }
        
    }
}
