//
//  ConvertCurrencyRaw.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal struct ConvertCurrencyRaw: Codable {
    
    internal let currency: String
    internal let label: String
    internal let sign: String
    internal let value: String
    
    internal enum CodingKeys: String, CodingKey {
        case currency = "currency"
        case label = "label"
        case sign = "sign"
        case value = "value"
    }
    
}
