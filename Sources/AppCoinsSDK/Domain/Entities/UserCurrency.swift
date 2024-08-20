//
//  UserCurrency.swift
//  
//
//  Created by Graciano Caldeira on 20/08/2024.
//

import Foundation

internal class UserCurrency: Codable {
    
    let currency: String
    let label: String
    let sign: String
    let value: String
    
    init(userCurrencyRaw: UserCurrencyRaw) {
        self.currency = userCurrencyRaw.currency
        self.label = userCurrencyRaw.label
        self.sign = userCurrencyRaw.sign
        self.value = userCurrencyRaw.value
    }
}
