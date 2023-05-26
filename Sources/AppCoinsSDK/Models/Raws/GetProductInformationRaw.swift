//
//  File.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

struct GetProductInformationRaw: Codable {
    
    let items: [ProductInformationRaw]?
    
    enum CodingKeys: String, CodingKey {
        case items = "items"
    }
    
}

struct ProductInformationRaw: Codable {
    
    let sku: String
    let title: String
    let description: String?
    let price: ProductPriceInformationRaw
    
    enum CodingKeys: String, CodingKey {
        case sku = "sku"
        case title = "title"
        case description = "description"
        case price = "price"
    }
    
}

struct ProductPriceInformationRaw: Codable {
    
    let currency: String
    let value: String
    let label: String
    let symbol: String
    
    enum CodingKeys: String, CodingKey {
        case currency = "currency"
        case value = "value"
        case label = "label"
        case symbol = "symbol"
    }
    
}
