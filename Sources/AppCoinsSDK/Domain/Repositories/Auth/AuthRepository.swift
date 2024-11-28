//
//  File.swift
//  
//
//  Created by aptoide on 28/11/2024.
//

import Foundation

internal class AuthRepository: AuthRepositoryProtocol {
    
    private let authService: AuthService = AuthClient()
    
    internal func authenticate(token: String) {
        authService.authenticate(token: token)
    }
}
