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
    let type: String?
    let flag: String?
    
    enum CodingKeys: String, CodingKey {
        case currency = "currency"
        case label = "label"
        case sign = "sign"
        case type = "type"
        case flag = "flag"
    }
    
    
}

internal struct CurrencyListRaw: Codable {
    
    let items: [CurrencyRaw]
    let next: Cursor?
    let previous: Cursor?
    
    enum CodingKeys: String, CodingKey {
        case items = "items"
        case next = "next"
        case previous = "previous"
    }
    
    internal struct Cursor: Codable {
        let cursor: String
        let query: String
        let url: String
        
        enum CodingKeys: String, CodingKey {
            case cursor = "cursor"
            case query = "query"
            case url = "url"
        }
    }
}
