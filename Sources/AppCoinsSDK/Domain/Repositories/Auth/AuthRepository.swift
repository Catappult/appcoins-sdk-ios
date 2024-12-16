//
//  File.swift
//  
//
//  Created by aptoide on 28/11/2024.
//

import Foundation

internal class AuthRepository: AuthRepositoryProtocol {
    
    private let authService: AuthService = AuthClient()
    private var state: String?
    
    internal func authenticate(token: String) {
        authService.authenticate(token: token)
    }
    
    internal func loginWithMagicLink(code: String, completion: @escaping (Result<UserAuthResponseRaw, AuthError>) -> Void) {
        authService.loginWithMagicLink(code: code, state: self.state ?? "") { result in completion(result) }
    }
    
    internal func sendMagicLink(email: String, completion: @escaping (Result<UserAuthResponseRaw, AuthError>) -> Void) {
        authService.sendMagicLink(email: email) { result in
            switch result {
            case .success(let data):
                self.state = data.state
            case .failure(_):
                break
            }
            
            completion(result)
        }
    }
}
