//
//  Currency.swift
//
//
//  Created by Graciano Caldeira on 16/08/2024.
//

import Foundation

internal class Currency: Codable {
    
    let currency: String
    let label: String
    let sign: String
    let type: String?
    let flag: URL?
    
    static let appcCurrency: Currency = Currency(currencyRaw: CurrencyRaw(currency: "APPC", label: "AppCoins", sign: "", type: "CRYPTO", flag: ""))
    
    init(convertCurrencyRaw: ConvertCurrencyRaw) {
        self.currency = convertCurrencyRaw.currency
        self.label = convertCurrencyRaw.label
        self.sign = convertCurrencyRaw.sign
        self.type = nil
        self.flag = nil
    }
    
    init(currencyRaw: CurrencyRaw) {
        self.currency = currencyRaw.currency
        self.label = currencyRaw.label
        self.sign = currencyRaw.sign
        self.type = currencyRaw.type
        self.flag = URL(string: currencyRaw.flag)
    }
}
