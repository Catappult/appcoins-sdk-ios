//
//  BrokerService.swift
//  AppCoinsSDK
//
//  Created by aptoide on 02/06/2025.
//

import Foundation

internal protocol BrokerService {
    
    func convertCurrency(money: String, fromCurrency: Currency, toCurrency: Currency?, result: @escaping (Result<ConvertCurrencyRaw, BrokerError>) -> Void)
    
    func getSupportedCurrencies(result: @escaping (Result<[CurrencyRaw], BrokerError>) -> Void)
}
