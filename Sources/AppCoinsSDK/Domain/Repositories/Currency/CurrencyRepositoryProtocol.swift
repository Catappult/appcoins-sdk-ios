//
//  CurrencyRepositoryProtocol.swift
//
//
//  Created by Graciano Caldeira on 20/08/2024.
//

import Foundation

internal protocol CurrencyRepositoryProtocol {
    func cacheUserCurrency()
    func getUserCurrency(completion: @escaping (Result<Currency, BillingError>) -> Void)
}
