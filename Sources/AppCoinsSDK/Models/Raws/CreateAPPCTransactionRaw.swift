//
//  CreateAPPCTransactionRaw.swift
//  
//
//  Created by aptoide on 17/05/2023.
//

import Foundation

internal struct CreateAPPCTransactionRaw: Codable {
    
    internal let origin: String?
    internal let domain: String
    internal let price: String?
    internal let priceCurrency: String
    internal let product: String?
    internal let type: String
    internal let developerWa: String
    internal let channel: String
    internal let metadata: String?
    internal let reference: String?
    internal let token: String
    
    internal enum CodingKeys: String, CodingKey {
        case origin = "origin"
        case domain = "domain"
        case price = "price.value"
        case priceCurrency = "price.currency"
        case product = "product"
        case type = "type"
        case developerWa = "wallets.developer"
        case channel = "channel"
        case metadata = "metadata"
        case reference = "reference"
        case token = "ios.token"
    }
    
    internal static func fromParameters(parameters: TransactionParameters) -> CreateAPPCTransactionRaw {
        // normalizes the price to adjust to different time zone price syntaxes
        let normalizedPrice = (parameters.appcAmount).replacingOccurrences(of: ",", with: ".")
        
        return CreateAPPCTransactionRaw(origin: "BDS", domain: parameters.domain, price: normalizedPrice, priceCurrency: "APPC", product: parameters.product, type: "INAPP", developerWa: parameters.developerWa, channel: "IOS", metadata: parameters.metadata, reference: parameters.reference, token: parameters.token
        )
    }
    
    internal func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
}

internal struct CreateTransactionResponseRaw: Codable {
    
    internal let uuid: String
    internal let status: CreateTransactionStatus
    internal let hash: String?
    
    internal enum CodingKeys: String, CodingKey {
        case uuid = "uid"
        case status = "status"
        case hash = "hash"
    }
    
}

internal enum CreateTransactionStatus: String, Codable {
    
    internal init(from decoder: Decoder) throws {
        self = try CreateTransactionStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .UNKNOWN
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

internal struct CreateTransactionErrorRaw: Codable {
    
    internal let code: String
    internal let path: String
    internal let text: String
    internal let data: CreateTransactionErrorDataRaw
    
    internal enum CodingKeys: String, CodingKey {
        case code = "code"
        case path = "path"
        case text = "text"
        case data = "data"
    }
}

internal struct CreateTransactionErrorDataRaw: Codable {
    
    internal let enduser: String
    internal let technical: String
    
    internal enum CodingKeys: String, CodingKey {
        case enduser = "enduser"
        case technical = "technical"
    }
    
}
