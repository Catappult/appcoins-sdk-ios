//
//  File.swift
//  
//
//  Created by aptoide on 28/11/2024.
//

import Foundation

internal protocol AuthService {
    
    func loginWithGoogle(code: String, completion: @escaping (Result<LoginWithMagicLinkResponseRaw, AuthError>) -> Void)
    func loginWithMagicLink(code: String, state: String, completion: @escaping (Result<LoginWithMagicLinkResponseRaw, AuthError>) -> Void)
    func sendMagicLink(email: String, completion: @escaping (Result<SendMagicLinkResponseRaw, AuthError>) -> Void)
    
}
