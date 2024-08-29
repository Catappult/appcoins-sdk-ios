//
//  TransferAPPCRaw.swift
//  
//
//  Created by aptoide on 02/10/2023.
//

import Foundation

internal struct TransferAPPCRaw: Codable {
    
    internal let domain: String
    internal let price: String?
    internal let priceCurrency: String
    internal let type: String
    internal let userWa: String
    internal let platform: String
    
    internal enum CodingKeys: String, CodingKey {
        case domain = "domain"
        case price = "price.value"
        case priceCurrency = "price.currency"
        case type = "type"
        case userWa = "wallets.user"
        case platform = "platform"
    }
    
    internal static func from(price: String, currency: String, userWa: String) -> TransferAPPCRaw {
        return TransferAPPCRaw (
            domain: BuildConfiguration.appcDomain, price: price, priceCurrency: currency, type: "TRANSFER", userWa: userWa, platform: "IOS"
        )
    }
    
    internal func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

internal struct TransferAPPCResponseRaw: Codable {
    
    internal let uuid: String
    internal let status: TransferAPPCTransactionStatus
    internal let hash: String?
    
    internal enum CodingKeys: String, CodingKey {
        case uuid = "uid"
        case status = "status"
        case hash = "hash"
    }
    
}

internal enum TransferAPPCTransactionStatus: String, Codable {
    
    internal init(from decoder: Decoder) throws {
        self = try TransferAPPCTransactionStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .UNKNOWN
    }
    
    case PENDING = "PENDING"
    case PENDING_SERVICE_AUTHORIZATION = "PENDING_SERVICE_AUTHORIZATION"
    case PROCESSING = "PROCESSING"
    case COMPLETED = "COMPLETED"
    case PENDING_USER_PAYMENT = "PENDING_USER_PAYMENT"
    case INVALID_TRANSACTION = "INVALID_TRANSACTION"
    case FAILED = "FAILED"
    case CANCELED = "CANCELED"
    case FRAUD = "FRAUD"
    case SETTLED = "SETTLED"
    case UNKNOWN
    
}


internal struct TransferAPPCTransactionErrorRaw: Codable {
    
    internal let code: String
    internal let path: String
    internal let text: String
    internal let data: TransferAPPCTransactionErrorDataRaw
    
    internal enum CodingKeys: String, CodingKey {
        case code = "code"
        case path = "path"
        case text = "text"
        case data = "data"
    }
}

internal struct TransferAPPCTransactionErrorDataRaw: Codable {
    
    internal let enduser: String
    internal let technical: String
    
    internal enum CodingKeys: String, CodingKey {
        case enduser = "enduser"
        case technical = "technical"
    }
    
}
