//
//  LoginViewModel.swift
//
//
//  Created by aptoide on 25/11/2024.
//

import Foundation
@_implementationOnly import AuthenticationServices

internal class LoginViewModel : NSObject, ObservableObject {
    
    internal static var shared : LoginViewModel = LoginViewModel()
    
    @Published internal var presentWebView : Bool = false
    @Published internal var loginMethod: LoginMethod? = nil
    
    private override init() {}
    
    internal func loginWithGoogle() {
        DispatchQueue.main.async {
            self.presentWebView = true
            self.loginMethod = LoginMethod.Google
            
            if let url = LoginMethod.Google.URL {
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
extension LoginViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
    }
}

internal struct LoginMethod {
    internal let baseURL: String
    internal let clientID: String
    internal let redirectURI: String
    internal let responseType: String
    internal let scope: [String]
    
    internal static let Google: LoginMethod = LoginMethod(
        baseURL: "https://accounts.google.com/o/oauth2/v2/auth",
        clientID: "71120307837-7e5c0pi0qfkmba0nlir6bf34acq1t1d9.apps.googleusercontent.com",
        redirectURI: "com.googleusercontent.apps.71120307837-7e5c0pi0qfkmba0nlir6bf34acq1t1d9:oauth2redirect",
        responseType: "code",
        scope: ["email"]
    )
    
    internal var URL: URL? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "response_type", value: responseType),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: scope.isEmpty ? "" : scope.joined(separator: " "))
        ]
        return components?.url
    }
}
