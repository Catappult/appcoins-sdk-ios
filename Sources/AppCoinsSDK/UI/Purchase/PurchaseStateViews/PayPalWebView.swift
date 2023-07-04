//
//  File.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import SwiftUI
import WebKit

struct PayPalWebView: UIViewRepresentable {
    var url: URL
    var method: String
    var successHandler: (_ token: String) -> Void
    var cancelHandler: (_ token: String?) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView
        
        var request = URLRequest(url: url)
        request.httpMethod = method

        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: PayPalWebView
        var webView: WKWebView?

        init(parent: PayPalWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // The web page finished loading
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
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
