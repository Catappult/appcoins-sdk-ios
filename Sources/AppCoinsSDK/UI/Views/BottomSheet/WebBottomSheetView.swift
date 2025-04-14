//
//  WebBottomSheetView.swift
//
//
//  Created by aptoide on 07/04/2025.
//

import Foundation
import WebKit
import SwiftUI

struct WebBottomSheetView: UIViewRepresentable {

    @ObservedObject var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
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
        
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.6), configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        if #available(iOS 16.4, *), BuildConfiguration.isDev { webView.isInspectable = true }

        BottomSheetViewModel.shared.webView = webView
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let guestUID = MMPUseCases.shared.getGuestUID(),
           let URL = URL(string: "https://wallet.dev.appcoins.io/iap/sdk?origin=BDS&type=INAPP&domain=com.appcoins.trivialdrivesample.test&product=antifreeze&country=PT&guest_uid=\(guestUID)&version=33&lang_code=PT_pt&payment_channel=ios_sdk"),
            webView.url != URL {
            webView.load(URLRequest(url: URL))
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
