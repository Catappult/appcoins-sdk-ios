//
//  File.swift
//  
//
//  Created by aptoide on 12/07/2024.
//

import Foundation

internal class GuestWallet: Wallet, Codable {
    
    internal let address: String
    internal let ewt: String
    internal let signature: String
    
    internal init(address: String, ewt: String, signature: String) {
        self.address = address
        self.ewt = ewt
        self.signature = signature
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
    
    func getSignedWalletAddress() -> String { return self.signature }
    
    func getAuthToken() -> String? { return "Bearer \(self.ewt)" }
    
    // Conform to Codable Protocol
    
    enum CodingKeys: String, CodingKey {
            case address
            case ewt
            case signature
        }
        
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(String.self, forKey: .address)
        ewt = try container.decode(String.self, forKey: .ewt)
        signature = try container.decode(String.self, forKey: .signature)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(ewt, forKey: .ewt)
        try container.encode(signature, forKey: .signature)
    }
}
