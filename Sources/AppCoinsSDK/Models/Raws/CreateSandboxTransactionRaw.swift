//
//  CreateSandboxTransactionRaw.swift
//
//
//  Created by aptoide on 28/08/2024.
//

import Foundation

internal struct CreateSandboxTransactionRaw: Codable {
    
    internal let domain: String
    internal let price: String?
    internal let priceCurrency: String
    internal let product: String?
    internal let type: String
    internal let channel: String
    internal let platform: String
    internal let guestUID: String?
    internal let oemID: String?
    internal let metadata: String?
    internal let reference: String?
    
    internal enum CodingKeys: String, CodingKey {
        case domain = "domain"
        case price = "price.value"
        case priceCurrency = "price.currency"
        case product = "product"
        case type = "type"
        case channel = "channel"
        case platform = "platform"
        case guestUID = "entity.guest_id"
        case oemID = "entity.oemid"
        case metadata = "metadata"
        case reference = "reference"
    }
    
    internal static func fromParameters(parameters: TransactionParameters) -> CreateSandboxTransactionRaw {
        // normalizes the price to adjust to different time zone price syntaxes
        let normalizedPrice = (parameters.appcAmount).replacingOccurrences(of: ",", with: ".")
        
        return CreateSandboxTransactionRaw(domain: parameters.domain, price: normalizedPrice, priceCurrency: "APPC", product: parameters.product, type: "INAPP", channel: "IOS", platform: "IOS", guestUID: parameters.guestUID, oemID: parameters.oemID, metadata: parameters.metadata, reference: parameters.reference
        )
    }
    
    internal func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
}

internal struct CreateSandboxTransactionResponseRaw: Codable {
    
    internal let uuid: String
    internal let status: CreateSandboxTransactionStatus
    internal let hash: String?
    
    internal enum CodingKeys: String, CodingKey {
        case uuid = "uid"
        case status = "status"
        case hash = "hash"
    }
    
}

internal enum CreateSandboxTransactionStatus: String, Codable {
    
    internal init(from decoder: Decoder) throws {
        self = try CreateSandboxTransactionStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .UNKNOWN
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

internal struct CreateSandboxTransactionErrorRaw: Codable {
    
    internal let code: String
    internal let path: String
    internal let text: String
    internal let data: CreateSandboxTransactionErrorDataRaw
    
    internal enum CodingKeys: String, CodingKey {
        case code = "code"
        case path = "path"
        case text = "text"
        case data = "data"
    }
}

internal struct CreateSandboxTransactionErrorDataRaw: Codable {
    
    internal let enduser: String
    internal let technical: String
    
    internal enum CodingKeys: String, CodingKey {
        case enduser = "enduser"
        case technical = "technical"
    }
    
}

