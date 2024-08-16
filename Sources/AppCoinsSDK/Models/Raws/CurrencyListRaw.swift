//
//  File.swift
//  
//
//  Created by Graciano Caldeira on 16/08/2024.
//

import Foundation

internal struct CurrencyListRaw: Codable {
    let items: [CurrencyRaw]
    let next: String?
    let previous: String?
    
    enum CodingKeys: String, CodingKey {
        case items = "items"
        case next = "next"
        case previous = "previous"
    }
}
