//
//  File.swift
//  
//
//  Created by aptoide on 28/11/2024.
//

import Foundation

internal class AuthUseCases {
    
    static var shared : AuthUseCases = AuthUseCases()
    
    private var repository: AuthRepositoryProtocol
    
    private init(repository: AuthRepositoryProtocol = AuthRepository()) {
        self.repository = repository
    }
    
    internal func refreshLogin() {}
    
    internal func loginWithGoogle(code: String, acceptedTC: Bool, consents: [String], completion: @escaping (Result<UserWallet, AuthError>) -> Void) {
        self.repository.loginWithGoogle(code: code, acceptedTC: acceptedTC, consents: consents) { result in completion(result) }
    }
    
    internal func loginWithMagicLink(code: String, acceptedTC: Bool, consents: [String], completion: @escaping (Result<UserWallet, AuthError>) -> Void) {
        self.repository.loginWithMagicLink(code: code, acceptedTC: acceptedTC, consents: consents) { result in completion(result) }
    }
    
    internal func sendMagicLink(email: String, acceptedTC: Bool, completion: @escaping (Result<Bool, AuthError>) -> Void) {
        self.repository.sendMagicLink(email: email, acceptedTC: acceptedTC) { result in completion(result) }
    }
    
    internal func logout() {
        self.repository.logout()
    }
}
