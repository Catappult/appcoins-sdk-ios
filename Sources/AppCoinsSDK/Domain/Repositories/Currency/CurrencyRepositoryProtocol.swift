//
//  CurrencyRepositoryProtocol.swift
//  AppCoinsSDK
//
//  Created by aptoide on 02/06/2025.
//

import Foundation

internal protocol CurrencyRepositoryProtocol {
    func getUserCurrency(completion: @escaping (Result<Currency, BrokerError>) -> Void)
    func getSupportedCurrencies(completion: @escaping (Result<[Currency], BrokerError>) -> Void)
    func getSupportedCurrency(currency: String, completion: @escaping (Result<Currency, BrokerError>) -> Void)
}
