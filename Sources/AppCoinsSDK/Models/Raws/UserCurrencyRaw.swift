//
//  UserCurrencyRaw.swift
//
//
//  Created by Graciano Caldeira on 20/08/2024.
//

import Foundation

internal struct UserCurrencyRaw: Codable {
    let currency: String
    let label: String
    let sign: String
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case currency = "currency"
        case label = "label"
        case sign = "sign"
        case value = "value"
    }
}
