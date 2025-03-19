//
//  AppCoinBillingService.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal protocol AppCoinBillingService {
    
    func convertCurrency(money: String, fromCurrency: Currency, toCurrency: Currency?, result: @escaping (Result<ConvertCurrencyRaw, BillingError>) -> Void)
    
    func getSupportedCurrencies(result: @escaping (Result<[CurrencyRaw], BillingError>) -> Void)
}
