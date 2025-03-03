//
//  File.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 03/03/2025.
//

import Foundation
import WebKit
import SwiftUI

struct WebBottomSheetView: UIViewRepresentable {
    let url: URL = URL(string: "https://wallet.dev.appcoins.io/iap/sdk?origin=BDS&type=INAPP&domain=com.appcoins.diceroll.sdk.dev&product=attempts&country=PT&metadata=user12345&reference=orderId%3D1730891513596&guestWalletID=6cdbdcfae8b682787da5e3cb90bed0099c0d80c6&version=135&lang_code=en")!

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
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
