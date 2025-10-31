//
//  Currency.swift
//  AppCoinsSDK
//
//  Created by aptoide on 02/06/2025.
//

import Foundation

internal class Currency: Codable {
    
    let currency: String
    let label: String
    let sign: String
    let type: String?
    let flag: URL?
    
    init(currency: String, label: String, sign: String, type: String?, flag: URL?) {
        self.currency = currency
        self.label = label
        self.sign = sign
        self.type = type
        self.flag = flag
    }
    
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
        
        if let flag = currencyRaw.flag { self.flag = URL(string: flag) }
        else { self.flag = nil }
    }
}

extension Currency {
    static let APPC: Currency = Currency(currency: "APPC", label: "AppCoins", sign: "", type: "CRYPTO", flag: nil)
}
