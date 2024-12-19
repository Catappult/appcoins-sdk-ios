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
    
    @Published internal var authState: AuthState = .choice
    @Published internal var isLoggedIn: Bool = false
    
    // Validate Magic Link E-mail
    @Published var magicLinkEmail: String = ""
    @Published var isMagicLinkEmailValid: Bool = true
    
    // Validate Magic Link Code
    @Published var magicLinkCode: String = ""
    @Published var isMagicLinkCodeValid: Bool = true

    @Published internal var showTextFieldWithKeyboard: Bool = false
    @Published internal var shouldFocusTextField: Bool = false

    @Published var isSendingMagicLink: Bool = false
    
    private override init() {}
    
    internal func reset() {
        self.authState = .choice
        self.magicLinkEmail = ""
        self.isMagicLinkEmailValid = true
        self.magicLinkCode = ""
        self.isMagicLinkCodeValid = true
    }
    
    internal func showTextFieldView() { self.showTextFieldWithKeyboard = true }
    
    internal func hideTextFieldView() { self.showTextFieldWithKeyboard = false }
    
    internal func setFocusTextField(shouldFocusTextField: Bool) { self.shouldFocusTextField = shouldFocusTextField }
    
    internal func setLogIn() { self.isLoggedIn = true }
    
    internal func setAuthState(state: AuthState) {
        self.authState = state
    }
    
    internal func validateEmail() -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        self.isMagicLinkEmailValid = emailPredicate.evaluate(with: self.magicLinkEmail)
        
        return isMagicLinkEmailValid
    }
    
    internal func loginWithGoogle() {
        DispatchQueue.main.async {
            self.presentWebView = true
            let googleBaseURL = "\(BuildConfiguration.aptoideIosServiceURL)/auth/user/login/social/google?domain=\(Bundle.main.bundleIdentifier ?? "")"
            
            if let url = URL(string: googleBaseURL) {
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
                        AuthUseCases.shared.loginWithGoogle(code: code) { result in
                            switch result {
                            case .success(let wallet):
                                DispatchQueue.main.async {
                                    TransactionViewModel.shared.buildTransaction() // Re-build the transaction with the new User Wallet
                                }
                            case .failure(let failure):
                                break // SOLVE BEFORE MERGING
                            }
                        }
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
    
    internal func sendMagicLink() {
        DispatchQueue.main.async { self.isSendingMagicLink = true }
        
        AuthUseCases.shared.sendMagicLink(email: self.magicLinkEmail) { result in
            DispatchQueue.main.async { 
                self.isSendingMagicLink = false
                self.authState = .magicLink
            }
        }
    }
    
    internal func loginWithMagicLink() {
        AuthUseCases.shared.loginWithMagicLink(code: self.magicLinkCode) { result in
            switch result {
            case .success(let wallet):
                DispatchQueue.main.async {
                    TransactionViewModel.shared.buildTransaction() // Re-build the transaction with the new User Wallet
                }
            case .failure(let failure):
                break // SOLVE BEFORE MERGING
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
