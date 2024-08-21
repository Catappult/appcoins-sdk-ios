//
//  CurrencyUseCases.swift
//
//
//  Created by Graciano Caldeira on 20/08/2024.
//

import Foundation

internal class CurrencyUseCases {
    
    internal static let shared: CurrencyUseCases = CurrencyUseCases()
    internal let repository: CurrencyRepositoryProtocol
    
    init(repository: CurrencyRepositoryProtocol = CurrencyRepository()) {
        self.repository = repository
    }
    
    internal func getUserCurrency(completion: @escaping (Result<Currency, BillingError>) -> Void) {
        repository.getUserCurrency { result in completion(result) }
    }
    
}
