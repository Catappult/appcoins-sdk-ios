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
    
    private let transactionService: AppCoinTransactionService = AppCoinTransactionClient()
    private let billingService: AppCoinBillingService = AppCoinBillingClient()
    
    internal init(address: String, ewt: String, signature: String) {
        self.address = address
        self.ewt = ewt
        self.signature = signature
    }

    func getBalance(currency: Coin, completion: @escaping (Result<Balance, AppcTransactionError>) -> Void) {
        transactionService.getBalance(wa: address) { result in
            switch result {
            case .success(let response):
                self.billingService.convertCurrency(money: String(response.usdBalance), fromCurrency: .USD, toCurrency: currency) {
                    result in
                    
                    switch result {
                    case .success(let currencyResponse):
                        let balance = Balance(balanceCurrency: currencyResponse.sign, balance: Double(currencyResponse.value) ?? 0.0, appcoinsBalance: response.appcNormalizedBalance)
                        completion(.success(balance))
                    case .failure(_):
                        completion(.failure(.failed))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
    
    func getWalletAddress() -> String { return self.address }
    
    func getSignedWalletAddress() -> String { return self.signature }
    
    func getEWT() -> String? { return self.ewt }
    
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
