//
//  BottomSheetView.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import SwiftUI
import WebKit

// Custom WebView for SwiftUI
struct WebView: UIViewRepresentable {
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
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
        }
    }
}

// Bottom Sheet View
struct BottomSheetView: View {
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @State private var isPresented = false
    
    var body: some View {
        ZStack {
            
            Color.black.opacity(0.3)
                .onTapGesture { viewModel.dismiss() }
                .ignoresSafeArea()
            
            ZStack {
                VStack(spacing: 0) {
                    Color.clear.frame(maxHeight: .infinity)
                    
                    VStack(spacing: 0) {
                        switch viewModel.purchaseState {
                        case .none:
                            ProgressView()
                        case .paying:
                            WebView()
                        default:
                            EmptyView()
                        }
                    }
                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width, height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : 620)
                    .cornerRadius(13, corners: [.topLeft, .topRight])
                    .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
                    .transition(.move(edge: isPresented ? .bottom : .top))
                    .onAppear { withAnimation { isPresented = true } }
                }.ignoresSafeArea()
            }
        
        
//        VStack {}
//            .sheet(isPresented: .constant(true)) {
//                if #available(iOS 16.0, *) {
//                    VStack {
//                        switch viewModel.purchaseState {
//                        case .none:
//                            ProgressView()
//                        case .paying:
//                            WebView()
//                        default:
//                            EmptyView()
//                        }
//                    }.presentationDetents([.fraction(0.5), .fraction(0.8)])
//                }
        }
    }
}

internal extension BottomSheetView {
    func toUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}
