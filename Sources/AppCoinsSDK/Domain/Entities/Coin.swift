//
//  File.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import Foundation

enum Coin: String {
    
    case ETH = "ETH"
    case APPC = "APPC"
    case EUR = "EUR"
    case USD = "USD"
    
}

extension Coin {
    
    var symbol: String {
        let locale = NSLocale(localeIdentifier: self.rawValue)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: self.rawValue) ?? ""
    }
    
}
