//
//  CurrencyRepository.swift
//
//
//  Created by Graciano Caldeira on 20/08/2024.
//

import Foundation

internal class CurrencyRepository: CurrencyRepositoryProtocol {

    internal let AppCoinBillingService: AppCoinBillingService  = AppCoinBillingClient()
    internal let UserCurrency: Cache<String, Currency> = Cache(cacheName: "UserCurrencyCache")

    internal func cacheUserCurrency() {
        AppCoinBillingService.cacheUserCurrency { result in
            switch result {
            case .success(let userCurrencyRaw):
                self.UserCurrency.setValue(Currency(userCurrencyRaw: userCurrencyRaw), forKey: "userCurrency", storageOption: .disk(ttl: 24 * 3600))
            case .failure: break
            }
        }
    }
    
    internal func getUserCurrency(completion: @escaping (Result<Currency, BillingError>) -> Void) {
        if let userCurrency = self.UserCurrency.getValue(forKey: "userCurrency") {
            completion(.success(userCurrency))
        } else {
            AppCoinBillingService.cacheUserCurrency { result in
                switch result {
                case .success(let userCurrencyRaw):
                    self.UserCurrency.setValue(Currency(userCurrencyRaw: userCurrencyRaw), forKey: "userCurrency", storageOption: .disk(ttl: 24 * 3600))
                    completion(.success(Currency(userCurrencyRaw: userCurrencyRaw)))
                case .failure(let error): completion(.failure(error))
                }
            }
        }
    }
}
