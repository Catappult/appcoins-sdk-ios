//
//  LoginViewModel.swift
//
//
//  Created by Graciano Caldeira on 16/12/2024.
//

import Foundation

internal class LoginViewModel: ObservableObject {
    
    internal static var shared: LoginViewModel = LoginViewModel()
    
    @Published var loginState: LoginState = .choice
    @Published var loginEmailText: String = ""
    @Published var magicLinkCode: String = ""
    @Published var isValidLoginEmail: Bool = true
    @Published var isMagicLinkCodeCorrect: Bool = true
    @Published var isLoggedIn: Bool = false
    
    private init() {}
    
    internal func login() { self.loginState = .choice }
    
    internal func magicLink() { self.loginState = .magicLink }
    
    internal func validateEmail() -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        self.isValidLoginEmail = emailPredicate.evaluate(with: self.loginEmailText)
        
        return isValidLoginEmail
    }
    
    internal func dismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !self.loginEmailText.isEmpty { self.loginEmailText = "" }
            if !self.isValidLoginEmail { self.isValidLoginEmail = true }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !self.magicLinkCode.isEmpty { self.magicLinkCode = "" }
            if !self.isMagicLinkCodeCorrect { self.isMagicLinkCodeCorrect = true }
        }
        
        self.loginState = .choice
    }
    
}
