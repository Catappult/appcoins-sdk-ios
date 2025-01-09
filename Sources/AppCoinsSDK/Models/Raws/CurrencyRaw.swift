//
//  File.swift
//  
//
//  Created by Graciano Caldeira on 16/08/2024.
//

import Foundation

internal struct CurrencyRaw: Codable {
    
    internal let currency: String
    internal let label: String
    internal let sign: String
    internal let type: String?
    internal let flag: String?
    
    internal enum CodingKeys: String, CodingKey {
        case currency = "currency"
        case label = "label"
        case sign = "sign"
        case type = "type"
        case flag = "flag"
    }
}

internal struct CurrencyListRaw: Codable {
    
    internal let items: [CurrencyRaw]
    internal let next: Cursor?
    internal let previous: Cursor?
    
    internal enum CodingKeys: String, CodingKey {
        case items = "items"
        case next = "next"
        case previous = "previous"
    }
}
