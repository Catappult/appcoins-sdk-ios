//
//  File.swift
//  
//
//  Created by Graciano Caldeira on 16/08/2024.
//

import Foundation

internal struct CurrencyRaw: Codable {
    
    let currency: String
    let label: String
    let sign: String
    let type: String
    let flag: String
    
    enum CodingKeys: String, CodingKey {
        case currency = "currency"
        case label = "label"
        case sign = "sign"
        case type = "type"
        case flag = "flag"
    }
}
