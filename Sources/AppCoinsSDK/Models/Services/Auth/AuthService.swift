//
//  AuthService.swift
//  
//
//  Created by aptoide on 28/11/2024.
//

import Foundation

internal protocol AuthService {
    
    func loginWithGoogle(code: String, acceptedTC: Bool, consents: [String], completion: @escaping (Result<LoginResponseRaw, AuthError>) -> Void)
    func loginWithMagicLink(code: String, state: String, acceptedTC: Bool, consents: [String], completion: @escaping (Result<LoginResponseRaw, AuthError>) -> Void)
    func sendMagicLink(email: String, acceptedTC: Bool, completion: @escaping (Result<SendMagicLinkResponseRaw, AuthError>) -> Void)
    
}
