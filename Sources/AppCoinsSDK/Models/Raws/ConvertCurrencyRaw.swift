//
//  ConvertCurrencyRaw.swift
//  AppCoinsSDK
//
//  Created by aptoide on 02/06/2025.
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
