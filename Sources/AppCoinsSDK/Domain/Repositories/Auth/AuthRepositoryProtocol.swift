//
//  File.swift
//  
//
//  Created by aptoide on 28/11/2024.
//

import Foundation

internal protocol AuthRepositoryProtocol {
    
    func getUserWallet(completion: @escaping (UserWallet?) -> Void)
    func authenticate(token: String)
    func loginWithMagicLink(code: String, completion: @escaping (Result<UserWallet, AuthError>) -> Void)
    func sendMagicLink(email: String, completion: @escaping (Result<Bool, AuthError>) -> Void)
    
}
