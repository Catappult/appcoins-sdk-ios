//
//  WebBottomSheetView.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 03/03/2025.
//

import Foundation
import WebKit
import SwiftUI

struct WebBottomSheetView: UIViewRepresentable {
    
    @ObservedObject var transactionViewModel: TransactionViewModel = TransactionViewModel.shared

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = transactionViewModel.webCheckoutURL, webView.url != url {
            webView.load(URLRequest(url: url))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebBottomSheetView

        init(_ parent: WebBottomSheetView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
        }
    }
}

internal extension BottomSheetView {
    func toUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}
