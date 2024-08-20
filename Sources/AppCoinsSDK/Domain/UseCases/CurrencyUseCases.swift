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
    
    internal func cacheUserCurrency() { repository.cacheUserCurrency() }
    
    internal func getUserCurrency() -> UserCurrency? {
        if let userCurrency = repository.getUserCurrency() {
            return userCurrency
        } else {
            return nil
        }
    }
    
}
