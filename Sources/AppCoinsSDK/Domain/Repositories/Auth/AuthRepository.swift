//
//  AuthRepository.swift
//
//
//  Created by aptoide on 28/11/2024.
//

import Foundation

internal class AuthRepository: AuthRepositoryProtocol {
    
    private let authService: AuthService = AuthClient()
    private let appcService: APPCService = APPCServiceClient()
    
    internal let AuthStateCache: Cache<String, String> = Cache<String, String>.shared(cacheName: "AuthStateCache")
    internal let AuthEmailCache: Cache<String, String> = Cache<String, String>.shared(cacheName: "AuthEmailCache")
    internal let UserWalletCache: Cache<String, UserWallet> = Cache<String, UserWallet>.shared(cacheName: "UserWalletCache")
    
    internal func getUserWallet(completion: @escaping (UserWallet?) -> Void) {
        if let userWallet = self.UserWalletCache.getValue(forKey: "userWallet") {
            if userWallet.isExpired() {
                self.refreshLogin(refreshToken: userWallet.refreshToken) { result in
                    switch result {
                    case .success(let refreshedWallet):
                        completion(refreshedWallet)
                    case .failure(let failure):
                        completion(nil)
                    }
                }
            } else {
                completion(userWallet)
            }
        } else {
            completion(nil) }
    }
    
    internal func loginWithGoogle(code: String, acceptedTC: Bool, consents: [String], completion: @escaping (Result<UserWallet, AuthError>) -> Void) {
        authService.loginWithGoogle(code: code, acceptedTC: acceptedTC, consents: consents) { result in
            switch result {
            case .success(let data):
                let userWallet = UserWallet(address: data.data.address, authToken: data.data.authToken, refreshToken: data.data.refreshToken, email: data.data.email)
                self.UserWalletCache.setValue(userWallet, forKey: "userWallet", storageOption: .disk(ttl: 60 * 60 * 24 * 365))
                completion(.success(userWallet))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    internal func loginWithMagicLink(code: String, acceptedTC: Bool, consents: [String], completion: @escaping (Result<UserWallet, AuthError>) -> Void) {
        if let state = self.AuthStateCache.getValue(forKey: "state") {
            authService.loginWithMagicLink(code: code, state: state, acceptedTC: acceptedTC, consents: consents) { result in
                switch result {
                case .success(let data):
                    let email = self.AuthEmailCache.getValue(forKey: "email")
                    let userWallet = UserWallet(address: data.data.address, authToken: data.data.authToken, refreshToken: data.data.refreshToken, email: email)
                    self.UserWalletCache.setValue(userWallet, forKey: "userWallet", storageOption: .disk(ttl: 60 * 60 * 24 * 365))
                    completion(.success(userWallet))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(.failed(message: "No State Stored on Magic Link Login", description: "No state stored to complete Magic Link Login flow at AuthRepository.swift:loginWithMagicLink", request: nil))) }
    }
    
    internal func sendMagicLink(email: String, acceptedTC: Bool, completion: @escaping (Result<Bool, AuthError>) -> Void) {
        // Cache user email
        self.AuthEmailCache.setValue(email, forKey: "email", storageOption: .disk(ttl: 86400))
        
        authService.sendMagicLink(email: email, acceptedTC: acceptedTC) { result in
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
    
    internal func refreshLogin(refreshToken: String, completion: @escaping (Result<UserWallet, AuthError>) -> Void) {
        var email: String? = nil
        if let currentWallet = self.UserWalletCache.getValue(forKey: "userWallet") {
            email = currentWallet.email
        }
        
        appcService.refreshUserWallet(refreshToken: refreshToken) { result in
            switch result {
            case .success(let raw):
                completion(.success(UserWallet(address: raw.address, authToken: raw.authToken, refreshToken: raw.refreshToken, email: email)))
            case .failure(let error):
                switch error {
                case .failed(let message, let description, let request):
                    completion(.failure(AuthError.failed(message: message, description: description, request: request)))
                case .noInternet(let message, let description, let request):
                    completion(.failure(AuthError.noInternet(message: message, description: description, request: request)))
                }
            }
        }
    }
    
    internal func logout() {
        self.UserWalletCache.removeValue(forKey: "userWallet")
    }
    
    internal func deleteAccount(email: String, completion: @escaping (Result<Bool, AuthError>) -> Void) {
        authService.deleteAccount(email: email) { result in
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
    
    internal func confirmDeleteAccount(code: String, completion: @escaping (Result<Bool, AuthError>) -> Void) {
        if let state = self.AuthStateCache.getValue(forKey: "state") {
            authService.confirmDeleteAccount(code: code, state: state) { result in
                switch result {
                case .success(let data):
                    self.UserWalletCache.removeValue(forKey: "userWallet")
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(.failed(message: "No State Stored on Delete Account", description: "No state stored to Delete Account at AuthRepository.swift:loginWithMagicLink", request: nil))) }
    }
}
