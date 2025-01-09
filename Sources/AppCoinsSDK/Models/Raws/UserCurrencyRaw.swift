//
//  UserCurrencyRaw.swift
//
//
//  Created by Graciano Caldeira on 20/08/2024.
//

import Foundation

internal struct UserCurrencyRaw: Codable {
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
