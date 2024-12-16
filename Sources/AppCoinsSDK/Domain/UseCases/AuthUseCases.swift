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
    
    internal func authenticate(token: String) {
        self.repository.authenticate(token: token)
    }
    
    internal func loginWithMagicLink(code: String, completion: @escaping (Result<UserAuthResponseRaw, AuthError>) -> Void) {
        self.repository.loginWithMagicLink(code: code) { result in completion(result) }
    }
    
    internal func sendMagicLink(email: String, completion: @escaping (Result<UserAuthResponseRaw, AuthError>) -> Void) {
        self.repository.sendMagicLink(email: email) { result in completion(result) }
    }
}
