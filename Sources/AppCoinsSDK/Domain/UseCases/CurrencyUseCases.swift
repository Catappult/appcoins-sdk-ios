//
//  CurrencyUseCases.swift
//  AppCoinsSDK
//
//  Created by aptoide on 02/06/2025.
//

import Foundation

internal class CurrencyUseCases {
    
    internal static let shared: CurrencyUseCases = CurrencyUseCases()
    internal let repository: CurrencyRepositoryProtocol
    
    init(repository: CurrencyRepositoryProtocol = CurrencyRepository()) {
        self.repository = repository
    }
    
    internal func getUserCurrency(completion: @escaping (Result<Currency, BrokerError>) -> Void) {
        repository.getUserCurrency { result in completion(result) }
    }
    
    internal func getSupportedCurrencies(completion: @escaping (Result<[Currency], BrokerError>) -> Void) {
        self.repository.getSupportedCurrencies { result in completion(result) }
    }
    
    internal func getSupportedCurrency(currency: String, completion: @escaping (Result<Currency, BrokerError>) -> Void) {
        repository.getSupportedCurrency(currency: currency) { result in completion(result) }
    }
}
