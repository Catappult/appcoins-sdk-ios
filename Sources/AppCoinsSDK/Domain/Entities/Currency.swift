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
    
    init(userCurrencyRaw: UserCurrencyRaw) {
        self.currency = userCurrencyRaw.currency
        self.label = userCurrencyRaw.label
        self.sign = userCurrencyRaw.sign
        self.type = nil
        self.flag = nil
    }
}