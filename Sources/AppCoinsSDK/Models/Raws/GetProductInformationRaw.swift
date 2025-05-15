//
//  GetProductInformationRaw.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal struct GetProductInformationRaw: Codable {
    
    internal let items: [ProductRaw]
    internal let next: Cursor?
    internal let previous: Cursor?
    
    internal enum CodingKeys: String, CodingKey {
        case items = "items"
        case next = "next"
        case previous = "previous"
    }
    
}

internal struct ProductRaw: Codable {
    
    internal let sku: String
    internal let title: String
    internal let description: String?
    internal let price: ProductPriceInformationRaw
    
    internal enum CodingKeys: String, CodingKey {
        case sku = "sku"
        case title = "title"
        case description = "description"
        case price = "price"
    }
    
    internal struct ProductPriceInformationRaw: Codable {
        
        internal let currency: String
        internal let value: String
        internal let label: String
        internal let symbol: String
        internal let discount: ProductPriceDiscountRaw?
        
        internal enum CodingKeys: String, CodingKey {
            case currency = "currency"
            case value = "value"
            case label = "label"
            case symbol = "symbol"
            case discount = "discount"
        }
     
        internal struct ProductPriceDiscountRaw: Codable {
            
            internal let percentage: String
            internal let value: String
            internal let label: String
            internal let micros: Int
            internal let policy: String
            internal let original: ProductPriceDiscountOriginalRaw
            
            internal enum CodingKeys: String, CodingKey {
                case percentage = "percentage"
                case value = "value"
                case label = "label"
                case micros = "micros"
                case policy = "policy"
                case original = "original"
            }
         
            internal struct ProductPriceDiscountOriginalRaw: Codable {
                
                internal let value: String
                internal let label: String
                internal let micros: Int
                
                internal enum CodingKeys: String, CodingKey {
                    case value = "value"
                    case label = "label"
                    case micros = "micros"
                }
                
            }
        }
    }
}


