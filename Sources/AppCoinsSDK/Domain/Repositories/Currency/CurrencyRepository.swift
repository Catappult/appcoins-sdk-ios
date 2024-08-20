//
//  CurrencyRepository.swift
//
//
//  Created by Graciano Caldeira on 16/08/2024.
//

import Foundation

internal class CurrencyRepository: CurrencyRepositoryProtocol {
    
    internal let AppCoinBillingService = AppCoinBillingClient()
    internal let CurrencyListCache: Cache<String, [Currency]> = Cache(cacheName: "CurrencyListCache")
    
    internal func getSupportedCurrencies(completion: @escaping (Result<[Currency], BillingError>) -> Void) {
        if let currencyList = self.CurrencyListCache.getValue(forKey: "currencyList") {
            completion(.success(currencyList))
        } else {
            self.AppCoinBillingService.getSupportedCurrencies { result in
                switch result {
                case .success(let currencyListRaw):
                    var currencyList: [Currency] = []
                    for itemRaw in currencyListRaw.items {
                        currencyList.append(Currency(currencyRaw: itemRaw))
                    }
                    self.CurrencyListCache.setValue(currencyList, forKey: "currencyList", storageOption: .disk(ttl: 24 * 3600))
                    completion(.success(currencyList))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
