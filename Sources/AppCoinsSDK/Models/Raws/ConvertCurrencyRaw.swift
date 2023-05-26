//
//  File.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

struct ConvertCurrencyRaw: Codable {
    
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
