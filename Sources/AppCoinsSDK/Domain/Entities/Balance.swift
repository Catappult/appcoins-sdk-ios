//
//  Balance.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal struct Balance: Codable {
    
    internal let balanceCurrency: Currency
    internal let balance: Double
    internal let appcoinsBalance: Double
    
    init(raw: AppCoinBalanceRaw, currency: Currency) {
        self.balanceCurrency = currency
        self.balance = raw.appcCFiatBalance
        self.appcoinsBalance = raw.appcCNormalizedBalance
    }
    
}
