//
//  File.swift
//  
//
//  Created by aptoide on 28/11/2024.
//

import Foundation

internal protocol AuthRepositoryProtocol {
    
    func authenticate(token: String)
    func loginWithMagicLink(code: String, completion: @escaping (Result<UserAuthResponseRaw, AuthError>) -> Void)
    func sendMagicLink(email: String, completion: @escaping (Result<UserAuthResponseRaw, AuthError>) -> Void)
    
}
