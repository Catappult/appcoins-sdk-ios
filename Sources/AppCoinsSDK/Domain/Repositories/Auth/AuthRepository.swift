//
//  File.swift
//  
//
//  Created by aptoide on 28/11/2024.
//

import Foundation

internal class AuthRepository: AuthRepositoryProtocol {
    
    private let authService: AuthService = AuthClient()
    internal let AuthStateCache: Cache<String, String> = Cache(cacheName: "AuthStateCache")
    internal let UserWalletCache: Cache<String, UserWallet> = Cache(cacheName: "UserWalletCache")
    
    internal func getUserWallet(completion: @escaping (UserWallet?) -> Void) {
        if let userWallet = self.UserWalletCache.getValue(forKey: "userWallet") {
            if userWallet.isExpired() {
                // Refresh user wallet
                completion(nil)
            } else {
                completion(userWallet)
            }
        } else { completion(nil) }
    }
    
    internal func loginWithGoogle(code: String, completion: @escaping (Result<UserWallet, AuthError>) -> Void) {
        authService.loginWithGoogle(code: code) { result in
            switch result {
            case .success(let data):
                let userWallet = UserWallet(address: data.data.address, authToken: data.data.authToken, refreshToken: data.data.refreshToken)
                self.UserWalletCache.setValue(userWallet, forKey: "userWallet", storageOption: .disk(ttl: 60 * 60 * 24 * 365))
                completion(.success(userWallet))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    internal func loginWithMagicLink(code: String, completion: @escaping (Result<UserWallet, AuthError>) -> Void) {
        if let state = self.AuthStateCache.getValue(forKey: "state") {
            authService.loginWithMagicLink(code: code, state: state) { result in
                switch result {
                case .success(let data):
                    let userWallet = UserWallet(address: data.data.address, authToken: data.data.authToken, refreshToken: data.data.refreshToken)
                    self.UserWalletCache.setValue(userWallet, forKey: "userWallet", storageOption: .disk(ttl: 60 * 60 * 24 * 365))
                    completion(.success(userWallet))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else { 
            print("No stored state")
            completion(.failure(.failed(message: "No State Stored on Magic Link Login", description: "No state stored to complete Magic Link Login flow at AuthRepository.swift:loginWithMagicLink", request: nil))) }
    }
    
    internal func sendMagicLink(email: String, completion: @escaping (Result<Bool, AuthError>) -> Void) {
        authService.sendMagicLink(email: email) { result in
            switch result {
            case .success(let data):
                if let state = data.state {
                    self.AuthStateCache.setValue(state, forKey: "state", storageOption: .disk(ttl: 86400)) // Valid for one day
                }
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
