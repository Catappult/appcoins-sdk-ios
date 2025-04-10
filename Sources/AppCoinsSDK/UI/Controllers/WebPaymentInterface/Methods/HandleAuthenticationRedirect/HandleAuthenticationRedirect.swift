//
//  HandleAuthenticationRedirect.swift
//
//
//  Created by aptoide on 07/04/2025.
//

import SwiftUI
@_implementationOnly import AuthenticationServices

internal class HandleAuthenticationRedirect: NSObject {
    
    internal static let shared = HandleAuthenticationRedirect()
    
    private override init() {}
    
    internal func handle(body: HandleAuthenticationRedirectBody) {
        if let authenticationURL = URL(string: body.URL) {
            // Initialize ASWebAuthenticationSession
            var authSession = ASWebAuthenticationSession(url: authenticationURL, callbackURLScheme: "\(Bundle.main.bundleIdentifier).iap") { callbackURL, error in
                
                if let error = error { return }
                guard let callbackURL = callbackURL else { return }
                
                BottomSheetViewModel.shared.handleWebViewDeeplink(deeplink: callbackURL.absoluteString)
                return
            }
            
            // Start the session
            authSession.presentationContextProvider = self
            authSession.start()
        }
    }
}

// Conform to ASWebAuthenticationPresentationContextProviding
extension HandleAuthenticationRedirect: ASWebAuthenticationPresentationContextProviding {
    internal func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
    }
}
