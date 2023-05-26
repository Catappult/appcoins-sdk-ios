//
//  File.swift
//  
//
//  Created by aptoide on 17/05/2023.
//

import Foundation

struct CreateTransactionRaw: Codable {
    
    let origin: String?
    let domain: String
    let price: String?
    let priceCurrency: String
    let product: String?
    let type: String
    let developerWa: String
    let metadata: String?
    let reference: String?
    
    enum CodingKeys: String, CodingKey {
        case origin = "origin"
        case domain = "domain"
        case price = "price.value"
        case priceCurrency = "price.currency"
        case product = "product"
        case type = "type"
        case developerWa = "wallets.developer"
        case metadata = "metadata"
        case reference = "reference"
    }
    
    static func getTransaction(domain: String, price: String, product: String, developerWa: String, metadata: String?, reference: String?) -> CreateTransactionRaw {
        return CreateTransactionRaw(
            origin: "BDS", domain: domain, price: price, priceCurrency: "APPC",
            product: product, type: "INAPP", developerWa: developerWa, metadata: metadata, reference: reference)
    }
    
//    origin=BDS&
//    domain=com.appcoins.trivialdrivesample.test&
//    price.value=99.73&
//    price.currency=APPC&
//    product=gas&
//    type=INAPP&
//    wallets.developer=0x123c2124b7f2c18b502296ba884d9cde201f1c32&
//    metadata=PAYLOAD%20TESTING&
//    reference=orderId%3D1684401478330
    
    func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
}

struct CreateTransactionResponseRaw: Codable {
    
    let uuid: String
    let status: CreateTransactionStatus
    let hash: String?
    
    enum CodingKeys: String, CodingKey {
        case uuid = "uid"
        case status = "status"
        case hash = "hash"
    }
    
}

enum CreateTransactionStatus: String, Codable {
    
    init(from decoder: Decoder) throws {
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

struct CreateTransactionErrorRaw: Codable {
    
    let code: String
    let path: String
    let text: String
    let data: CreateTransactionErrorDataRaw
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case path = "path"
        case text = "text"
        case data = "data"
    }
    
}

struct CreateTransactionErrorDataRaw: Codable {
    
    let enduser: String
    let technical: String
    
    enum CodingKeys: String, CodingKey {
        case enduser = "enduser"
        case technical = "technical"
    }
    
}
