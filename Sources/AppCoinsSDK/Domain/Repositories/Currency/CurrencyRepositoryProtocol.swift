//
//  CurrencyRepositoryProtocol.swift
//  
//
//  Created by Graciano Caldeira on 16/08/2024.
//

import Foundation

internal protocol CurrencyRepositoryProtocol {
    func getUserCurrency(completion: @escaping (Result<Currency, BillingError>) -> Void)
    func getSupportedCurrencies(completion: @escaping (Result<[Currency], BillingError>) -> Void)
}
