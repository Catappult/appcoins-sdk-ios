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
        guard let authenticationURL = URL(string: body.URL) else {
            Utils.log("Invalid URL at HandleAuthenticationRedirect.swift:handle")
            return
        }
      
        // Initialize ASWebAuthenticationSession
        var authSession = ASWebAuthenticationSession(url: authenticationURL, callbackURLScheme: "\(Bundle.main.bundleIdentifier).iap") { callbackURL, error in
            
            if let error = error {
                Utils.log("Error on handleAuthenticationRedirect: \(error.localizedDescription)", level: .error)
                return
            }
            guard let callbackURL = callbackURL else {
                Utils.log("Invalid callback URL at HandleAuthenticationRedirect.swift:handle")
                return
            }
            
            PurchaseViewModel.shared.handleWebViewDeeplink(deeplink: callbackURL.absoluteString)
            return
        }
        
        // Start the session
        authSession.presentationContextProvider = self
        authSession.start()
    }
}

// Conform to ASWebAuthenticationPresentationContextProviding
extension HandleAuthenticationRedirect: ASWebAuthenticationPresentationContextProviding {
    internal func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
    }
}
