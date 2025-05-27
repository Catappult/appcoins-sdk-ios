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
    
    @Published internal var hasConsentedEmailStorage: Bool = false
    @Published internal var hasAcceptedTC: Bool = false
    @Published internal var presentTCError: Bool = false
    
    @Published internal var manageAccountState: ManageAccountState = .manage
    
    @Published internal var isLogoutAlertPresented: Bool = false
    @Published internal var isDeleteAccountAlertPresented: Bool = false
    @Published internal var deleteAccountEmail: String = ""
    
    @Published internal var isSendingDelete: Bool = false
    @Published internal var sentDelete: Date?
    @Published internal var retryDeleteTimer: Timer?
    @Published internal var retryDeleteIn: Int = 0
    
    private override init() {}
    
    internal func reset() {
        self.authState = .choice
        self.magicLinkEmail = ""
        self.isMagicLinkEmailValid = true
        self.isSendingMagicLink = false
        self.hasConsentedEmailStorage = false
        self.hasAcceptedTC = false
        self.presentTCError = false
        
        self.manageAccountState = .manage
        self.isLogoutAlertPresented = false
        self.isDeleteAccountAlertPresented = false
        self.deleteAccountEmail = ""
        
        self.isSendingDelete = false
        self.sentDelete = nil
        self.retryDeleteTimer = nil
        self.retryDeleteIn = 0
    }
    
    internal func showFocusedTextField() { DispatchQueue.main.async { self.isTextFieldFocused = true } }
    
    internal func hideFocusedTextField() { DispatchQueue.main.async { self.isTextFieldFocused = false } }
    
    internal func setLogInState(isLoggedIn: Bool) { DispatchQueue.main.async { self.isLoggedIn = isLoggedIn } }
    
    internal func setAuthState(state: AuthState) {
        self.authState = state
    }
    
    internal func validateEmail(email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    internal func validateTCAcceptance() -> Bool {
        if self.hasAcceptedTC { return true }
        else {
            DispatchQueue.main.async { self.presentTCError = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { self.presentTCError = false } // Set value back to origin after displaying error
            return false
        }
    }
    
    internal func loginWithGoogle() {
        guard self.validateTCAcceptance() else { return }
        
        DispatchQueue.main.async {
            self.presentWebView = true
            let googleBaseURL = "\(BuildConfiguration.aptoideIosServiceURL)/auth/user/login/social/google?domain=\(Bundle.main.bundleIdentifier ?? "")"
            
            if let url = URL(string: googleBaseURL) {
                // Initialize ASWebAuthenticationSession
                var authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: "\(Bundle.main.bundleIdentifier).iap") { callbackURL, error in
                    
                    if let error = error {
                        if let asError = error as? ASWebAuthenticationSessionError,
                           asError.code == .canceledLogin {
                            DispatchQueue.main.async { self.authState = .choice } // Handle user cancellation
                        } else {
                            DispatchQueue.main.async { self.authState = .error } // Handle other errors
                        }
                        return
                    }
                    
                    guard let callbackURL = callbackURL, let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems else {
                        DispatchQueue.main.async { self.authState = .error }
                        return
                    }
                    
                    if let code = queryItems.first(where: { $0.name == "code" })?.value {
                        DispatchQueue.main.async { self.authState = .loading }
                        
                        var consents: [String] = []
                        if self.hasConsentedEmailStorage { consents.append("email") }
                        AuthUseCases.shared.loginWithGoogle(code: code, acceptedTC: self.hasAcceptedTC, consents: consents) { result in
                            switch result {
                            case .success(let wallet):
                                self.setLoginSuccess()
                            case .failure(let failure):
                                switch failure {
                                    case .failed: DispatchQueue.main.async { self.authState = .error }
                                    case .noInternet: DispatchQueue.main.async { self.authState = .noInternet }
                                }
                            }
                        }
                    } else if let errorDescription = queryItems.first(where: { $0.name == "error" })?.value {
                        DispatchQueue.main.async { self.authState = .error }
                    } else {
                        DispatchQueue.main.async { self.authState = .error }
                    }
                }
                
                // Start the session
                authSession.presentationContextProvider = self
                authSession.start()
            }
        }
    }
    
    internal func sendMagicLink() {
        guard self.validateEmail(email: self.magicLinkEmail) else { return }
        guard self.validateTCAcceptance() else { return }
        
        DispatchQueue.main.async {
            self.isMagicLinkEmailValid = true
            self.isSendingMagicLink = true
        }

        AuthUseCases.shared.sendMagicLink(email: self.magicLinkEmail, acceptedTC: self.hasAcceptedTC) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.startRetryMagicLinkTimer()
                    self.isSendingMagicLink = false
                    self.authState = .magicLink
                }
            case .failure(let failure):
                switch failure {
                    case .failed: DispatchQueue.main.async { self.authState = .error }
                    case .noInternet: DispatchQueue.main.async { self.authState = .noInternet }
                }
            }
        }
    }
    
    internal func loginWithMagicLink(code: String) {
        if !(BottomSheetViewModel.shared.purchaseState == .login && self.authState == .magicLink) { return } // Do not allow magic link login outside regular flow
        
        self.stopRetryMagicLinkTimer()
        DispatchQueue.main.async { self.authState = .loading }
        
        var consents: [String] = []
        if self.hasConsentedEmailStorage { consents.append("email") }
        AuthUseCases.shared.loginWithMagicLink(code: code, acceptedTC: self.hasAcceptedTC, consents: consents) { result in
            switch result {
            case .success(let wallet):
                self.setLoginSuccess()
            case .failure(let failure):
                switch failure {
                    case .failed: DispatchQueue.main.async { self.authState = .error }
                    case .noInternet: DispatchQueue.main.async { self.authState = .noInternet }
                }
            }
        }
    }
    
    private func setLoginSuccess() {
        if BottomSheetViewModel.shared.hasCompletedPurchase() {
            TransactionViewModel.shared.transferBonusOnLogin() { result in
                switch result {
                case .success(let success):
                    DispatchQueue.main.async { self.authState = .success }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                        BottomSheetViewModel.shared.transactionSucceeded()
                    }
                case .failure(let failure):
                    AuthUseCases.shared.logout()
                    switch failure {
                    case .noInternet: DispatchQueue.main.async { self.authState = .noInternet }
                    default: DispatchQueue.main.async { self.authState = .error }
                    }
                }
            }
            
        } else {
            DispatchQueue.main.async { self.authState = .success }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                TransactionViewModel.shared.rebuildTransactionOnWalletChanged() // Re-build the transaction with the new User Wallet
            }
        }
    }
    
    internal func showLogoutAlert() {
        DispatchQueue.main.async { self.isLogoutAlertPresented = true }
    }
    
    internal func logout() {
        AuthUseCases.shared.logout()
        BottomSheetViewModel.shared.dismissManageAccountSheet()
        TransactionViewModel.shared.rebuildTransactionOnWalletChanged() // Re-build the transaction with the new Client Wallet
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.reset()
        }
    }
    
    internal func presentDeleteAccountAlert() {
        WalletUseCases.shared.getWallet { result in
            if case .success(let wallet) = result, let wallet = wallet as? UserWallet, let email = wallet.getEmail() {
                self.deleteAccountEmail = email
            }
            
            DispatchQueue.main.async { [self] in
                self.isDeleteAccountAlertPresented = true
                print("[AppCoinsSDK] isDeleteAccountAlertPresented: \(self.isDeleteAccountAlertPresented)")
            }
        }
    }
    
    internal func dismissDeleteAccountAlert() { DispatchQueue.main.async { self.isDeleteAccountAlertPresented = false } }
    
    internal func deleteAccount() {
        DispatchQueue.main.async { self.isSendingDelete = true }
            
        AuthUseCases.shared.deleteAccount(email: self.deleteAccountEmail) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.startRetryDeleteTimer()
                    self.isSendingDelete = false
                    self.isDeleteAccountAlertPresented = false
                    self.manageAccountState = .deleteSent
                }
            case .failure(let failure):
                switch failure {
                    case .failed: DispatchQueue.main.async { self.manageAccountState = .deleteFailed }
                    case .noInternet: DispatchQueue.main.async { self.manageAccountState = .deleteFailed }
                }
            }
        }
    }
    
    internal func confirmDelete(code: String) {
        if !(BottomSheetViewModel.shared.isManageAccountSheetPresented && self.manageAccountState == .deleteSent) { return } // Do not allow delete outside regular flow
        
        self.stopRetryDeleteTimer()
        DispatchQueue.main.async { self.manageAccountState = .deleteLoading }
        
        AuthUseCases.shared.confirmDeleteAccount(code: code) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async { self.manageAccountState = .deleteSuccess }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                    BottomSheetViewModel.shared.dismissManageAccountSheet()
                    TransactionViewModel.shared.rebuildTransactionOnWalletChanged() // Re-build the transaction with the new User Wallet
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.reset()
                    }
                }
            case .failure(let failure):
                DispatchQueue.main.async { self.manageAccountState = .deleteFailed }
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
    
    private func stopRetryMagicLinkTimer() {
        retryMagicLinkTimer?.invalidate()
        retryMagicLinkTimer = nil
    }
    
    internal func tryAgain() {
        if BottomSheetViewModel.shared.hasCompletedPurchase() {
            DispatchQueue.main.async { self.setAuthState(state: .choice) }
        } else {
            DispatchQueue.main.async { BottomSheetViewModel.shared.setPurchaseState(newState: .paying) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.reset() }
        }
    }
    
    internal func startRetryDeleteTimer() {
        self.sentDelete = Date()
        updateRetryDeleteIn() // Initialize the value immediately
        
        retryDeleteTimer?.invalidate() // Ensure there's no existing timer
        retryDeleteTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateRetryDeleteIn()
        }
    }
    
    private func updateRetryDeleteIn() {
        guard let sentDelete = sentDelete else {
            retryDeleteIn = 0
            retryDeleteTimer?.invalidate() // Stop the timer if there's no sentDelete
            return
        }
        
        let secondsPassed = Date().timeIntervalSince(sentDelete)
        let timeLeft = 30 - secondsPassed
        retryDeleteIn = max(0, Int(timeLeft))
        
        if retryDeleteIn == 0 {
            retryDeleteTimer?.invalidate() // Stop the timer when the countdown reaches 0
        }
    }
    
    private func stopRetryDeleteTimer() {
        retryDeleteTimer?.invalidate()
        retryDeleteTimer = nil
    }
    
    internal func tryAgainDelete() {
        DispatchQueue.main.async { self.reset() }
    }
}

// Conform to ASWebAuthenticationPresentationContextProviding
extension AuthViewModel: ASWebAuthenticationPresentationContextProviding {
    internal func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
    }
}
