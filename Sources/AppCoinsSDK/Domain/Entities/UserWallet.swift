//
//  File.swift
//  
//
//  Created by aptoide on 16/12/2024.
//

import Foundation

internal class UserWallet: Wallet, Codable {
    
    internal let address: String
    internal let authToken: String
    internal let refreshToken: String
    internal let added: Date
    
    internal init(address: String, authToken: String, refreshToken: String) {
        self.address = address
        self.authToken = authToken
        self.refreshToken = refreshToken
        self.added = Date()
    }

    func getBalance(completion: @escaping (Result<Balance, AppcTransactionError>) -> Void) {
        CurrencyUseCases.shared.getUserCurrency { result in
            switch result {
            case .success(let currency):
                WalletUseCases.shared.getWalletBalance(wallet: self, currency: currency) { result in
                    switch result {
                    case .success(let balance):
                        completion(.success(balance))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                switch error {
                case .failed(let message, let description, let request):
                    completion(.failure(AppcTransactionError.failed(message: message, description: description, request: request)))
                case .noInternet(let message, let description, let request):
                    completion(.failure(AppcTransactionError.noInternet(message: message, description: description, request: request)))
                }
            }
        }
    }
    
    func getWalletAddress() -> String { return self.address }
    
    func getAuthToken() -> String? { return "Bearer \(self.authToken)" }
    
    func isExpired() -> Bool {
        let minutesLived = -self.added.timeIntervalSinceNow / 60
        return minutesLived > 10 // Is expired if it was fetched more than 10 minutes ago
    }
    
    // Conform to Codable Protocol
    enum CodingKeys: String, CodingKey {
            case address
            case authToken
            case refreshToken
            case added
        }
        
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(String.self, forKey: .address)
        authToken = try container.decode(String.self, forKey: .authToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        added = try container.decode(Date.self, forKey: .added)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(authToken, forKey: .authToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(added, forKey: .added)
    }
}
