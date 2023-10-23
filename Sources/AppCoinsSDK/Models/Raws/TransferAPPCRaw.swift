//
//  TransferAPPCRaw.swift
//  
//
//  Created by aptoide on 02/10/2023.
//

import Foundation

internal struct TransferAPPCRaw: Codable {
    
    internal let origin: String?
    internal let domain: String
    internal let price: String?
    internal let priceCurrency: String
    internal let type: String
    internal let userWa: String
    
    internal enum CodingKeys: String, CodingKey {
        case origin = "origin"
        case domain = "domain"
        case price = "price.value"
        case priceCurrency = "price.currency"
        case type = "type"
        case userWa = "wallets.user"
    }
    
    internal static func from(price: String, currency: String, userWa: String) -> TransferAPPCRaw {
        return TransferAPPCRaw (
            origin: "BDS", domain: BuildConfiguration.appcDomain, price: price, priceCurrency: currency, type: "TRANSFER", userWa: userWa
        )
    }
    
    internal func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

internal struct TransferAPPCResponseRaw: Codable {
    
    internal let uuid: String
    internal let status: CreateTransactionStatus
    internal let hash: String?
    
    internal enum CodingKeys: String, CodingKey {
        case uuid = "uid"
        case status = "status"
        case hash = "hash"
    }
    
}
