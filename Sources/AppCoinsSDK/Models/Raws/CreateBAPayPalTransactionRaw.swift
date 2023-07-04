//
//  File.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import Foundation

public struct CreateBAPayPalTransactionRaw: Codable {
    
    let origin: String?
    let domain: String
    let price: String?
    let priceCurrency: String
    let product: String?
    let type: String
    let developerWa: String
    let userWa: String
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
        case userWa = "wallets.user"
        case metadata = "metadata"
        case reference = "reference"
    }
    
    static func fromDictionary(dictionary: [String : String]) -> CreateBAPayPalTransactionRaw {
        // normalizes the price to adjust to different time zone price syntaxes
        let normalizedPrice = (dictionary["value"] ?? "0.0").replacingOccurrences(of: ",", with: ".")
        
        var metadata: String?
        if dictionary["metadata"] == "" { metadata = nil } else { metadata = dictionary["metadata"] }
        var reference: String?
        if dictionary["reference"] == "" { reference = nil } else { reference = dictionary["reference"] }
        
        return CreateBAPayPalTransactionRaw(
            origin: "BDS", domain: dictionary["domain"]!, price: normalizedPrice, priceCurrency: dictionary["currency"]!,
            product: dictionary["product"], type: "INAPP", developerWa: dictionary["developerWa"]!, userWa: dictionary["userWa"]!,
            metadata: metadata, reference: reference
        )
    }
    
    func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
}

public struct CreateBAPayPalTransactionResponseRaw: Codable {
    
    let uuid: String
    let status: CreateBAPayPalTransactionStatus
    let hash: String?
    
    enum CodingKeys: String, CodingKey {
        case uuid = "uid"
        case status = "status"
        case hash = "hash"
    }
    
}

public struct CreateBAPayPalBillingAgreementNotFoundResponseRaw: Codable {
    
    let code: String
    let path: String?
    let text: String?
    let data: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case path = "path"
        case text = "text"
        case data = "data"
    }
    
}

public enum CreateBAPayPalTransactionStatus: String, Codable {
    
    public init(from decoder: Decoder) throws {
        self = try CreateBAPayPalTransactionStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .UNKNOWN
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
