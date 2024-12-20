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
    @Published internal var magicLinkEmail: String = ""
    @Published internal var isMagicLinkEmailValid: Bool = true

    @Published internal var isTextFieldFocused: Bool = false

    @Published internal var isSendingMagicLink: Bool = false
    @Published internal var sentMagicLink: Date?
    @Published internal var retryMagicLinkTimer: Timer?
    @Published internal var retryMagicLinkIn: Int = 0
    
    private override init() {}
    
    internal func reset() {
        self.authState = .choice
        self.magicLinkEmail = ""
        self.isMagicLinkEmailValid = true
    }
    
    internal func showFocusedTextField() { self.isTextFieldFocused = true }
    
    internal func hideFocusedTextField() { self.isTextFieldFocused = false }
    
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
                        DispatchQueue.main.async { self.authState = .loading }
                        
                        print("Code: \(code)")
                        AuthUseCases.shared.loginWithGoogle(code: code) { result in
                            switch result {
                            case .success(let wallet):
                                DispatchQueue.main.async { self.authState = .success }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
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
                self.startRetryMagicLinkTimer()
                self.isSendingMagicLink = false
                self.authState = .magicLink
            }
        }
    }
    
    internal func loginWithMagicLink(code: String) {
        self.stopRetryMagicLinkTimer()
        DispatchQueue.main.async { self.authState = .loading }
        
        AuthUseCases.shared.loginWithMagicLink(code: code) { result in
            switch result {
            case .success(let wallet):
                DispatchQueue.main.async { self.authState = .success }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    TransactionViewModel.shared.buildTransaction() // Re-build the transaction with the new User Wallet
                }
            case .failure(let failure):
                break // SOLVE BEFORE MERGING
            }
        }
    }
    
    internal func startRetryMagicLinkTimer() {
        self.sentMagicLink = Date()
        updateRetryMagicLinkIn() // Initialize the value immediately

        retryMagicLinkTimer?.invalidate() // Ensure there's no existing timer
        retryMagicLinkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateRetryMagicLinkIn()
        }
    }

    private func updateRetryMagicLinkIn() {
        guard let sentMagicLink = sentMagicLink else {
            retryMagicLinkIn = 0
            retryMagicLinkTimer?.invalidate() // Stop the timer if there's no sentMagicLink
            return
        }

        let secondsPassed = Date().timeIntervalSince(sentMagicLink)
        let timeLeft = 30 - secondsPassed
        retryMagicLinkIn = max(0, Int(timeLeft))

        if retryMagicLinkIn == 0 {
            retryMagicLinkTimer?.invalidate() // Stop the timer when the countdown reaches 0
        }
    }

    func stopRetryMagicLinkTimer() {
        retryMagicLinkTimer?.invalidate()
        retryMagicLinkTimer = nil
    }
}

// Conform to ASWebAuthenticationPresentationContextProviding
extension AuthViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
    }
}
