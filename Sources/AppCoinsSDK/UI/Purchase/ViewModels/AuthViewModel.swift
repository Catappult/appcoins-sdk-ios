//
//  AuthViewModel.swift
//
//
//  Created by aptoide on 25/11/2024.
//

import Foundation
@_implementationOnly import AuthenticationServices

internal class AuthViewModel : NSObject, ObservableObject {
    
    internal static var shared : AuthViewModel = AuthViewModel()
    
    @Published internal var presentWebView : Bool = false
    @Published internal var loginMethod: LoginMethod? = nil
    
    private override init() {}
    
    internal func loginWithGoogle() {
        DispatchQueue.main.async {
            self.presentWebView = true
            self.loginMethod = LoginMethod.Google
            
            if let url = URL(string: LoginMethod.Google.baseURL) {
                // Initialize ASWebAuthenticationSession
                var authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: "\(Bundle.main.bundleIdentifier).iap") { callbackURL, error in
                    
                    if let error = error {
                        print(error)
                    }
                    
                    guard let callbackURL = callbackURL, let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems else {
                        print("Invalid callback URL")
                        return
                    }
                    
                    if let code = queryItems.first(where: { $0.name == "code" })?.value {
                        print("Code: \(code)")
                        AuthUseCases.shared.authenticate(token: code)
                    } else if let errorDescription = queryItems.first(where: { $0.name == "error" })?.value {
                        print("Error: \(errorDescription)")
                    } else {
                        print("Error: Unknown error")
                    }
                }
                
                // Start the session
                authSession.presentationContextProvider = self
                authSession.start()
            }
        }
    }
}

// Conform to ASWebAuthenticationPresentationContextProviding
extension AuthViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
    }
}

internal struct LoginMethod {
    internal let baseURL: String
    
    internal static let Google: LoginMethod = LoginMethod(
        baseURL: "http://localhost:8000/aptoide-ios/8.20240930/auth/google?domain=\(Bundle.main.bundleIdentifier ?? "")"
    )
}
