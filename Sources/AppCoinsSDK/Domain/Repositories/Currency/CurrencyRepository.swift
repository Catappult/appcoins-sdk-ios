//
//  File.swift
//  
//
//  Created by Graciano Caldeira on 20/08/2024.
//

import Foundation

internal class CurrencyRepository: CurrencyRepositoryProtocol {

    internal let AppCoinBillingService: AppCoinBillingService  = AppCoinBillingClient()
    internal let UserCurrency: Cache<String, UserCurrency> = Cache(cacheName: "UserCurrencyCache")

    internal func cacheUserCurrency() {
        AppCoinBillingService.cacheUserCurrency { result in
            switch result {
            case .success(let userCurrencyRaw):
                self.UserCurrency.setValue(AppCoinsSDK.UserCurrency(userCurrencyRaw: userCurrencyRaw), forKey: "userCurrency", storageOption: .disk(ttl: 24 * 3600))
            case .failure: break
            }
        }
    }
    
    internal func getUserCurrency() -> UserCurrency? {
        if let userCurrency = self.UserCurrency.getValue(forKey: "userCurrency") {
            return userCurrency
        } else {
            return nil
        }
    }
}
