//
//  CurrencyRepository.swift
//  AppCoinsSDK
//
//  Created by aptoide on 02/06/2025.
//

import Foundation

internal class CurrencyRepository: CurrencyRepositoryProtocol {

    internal let BrokerService: BrokerService  = BrokerClient()
    internal let UserCurrency: Cache<String, Currency> = Cache<String, Currency>.shared(cacheName: "UserCurrencyCache")
    internal let CurrencyListCache: Cache<String, [Currency]> = Cache<String, [Currency]>.shared(cacheName: "CurrencyListCache")

    internal func getUserCurrency(completion: @escaping (Result<Currency, BrokerError>) -> Void) {
        if let userCurrency = self.UserCurrency.getValue(forKey: "userCurrency") {
            completion(.success(userCurrency))
        } else {
            BrokerService.convertCurrency(money: "1.0", fromCurrency: Currency.APPC, toCurrency: nil) { result in
                switch result {
                case .success(let userCurrencyRaw):
                    self.UserCurrency.setValue(Currency(convertCurrencyRaw: userCurrencyRaw), forKey: "userCurrency", storageOption: .memory)
                    completion(.success(Currency(convertCurrencyRaw: userCurrencyRaw)))
                case .failure(let error): completion(.failure(error))
                }
            }
        }
    }
    
    internal func getSupportedCurrencies(completion: @escaping (Result<[Currency], BrokerError>) -> Void) {
        if let currencyList = self.CurrencyListCache.getValue(forKey: "currencyList") {
            completion(.success(currencyList))
        } else {
            self.BrokerService.getSupportedCurrencies { result in
                switch result {
                case .success(let currencyListRaw):
                    var currencyList: [Currency] = []
                    for itemRaw in currencyListRaw {
                        currencyList.append(Currency(currencyRaw: itemRaw))
                    }
                    self.CurrencyListCache.setValue(currencyList, forKey: "currencyList", storageOption: .disk(ttl: 30 * 24 * 3600))
                    completion(.success(currencyList))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    internal func getSupportedCurrency(currency: String, completion: @escaping (Result<Currency, BrokerError>) -> Void) {
        self.getSupportedCurrencies { result in
            switch result {
            case .success(let supportedCurrencies):
                if let supportedCurrency = supportedCurrencies.first(where: { $0.currency == currency }) {
                    completion(.success(supportedCurrency))
                } else { completion(.failure(.failed(message: "Failed to get supported currency", description: "Received unsupported currency: \(currency) at CurrencyRepository.swift:getSupportedCurrency", request: nil))) }
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
}
