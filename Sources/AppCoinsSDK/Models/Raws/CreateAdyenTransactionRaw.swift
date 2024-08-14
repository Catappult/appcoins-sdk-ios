//
//  CreateAdyenTransactionRaw.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import Foundation

internal struct CreateAdyenTransactionRaw: Codable {
    
    internal let origin: String?
    internal let domain: String
    internal let price: String?
    internal let priceCurrency: String
    internal let product: String?
    internal let type: String
    internal let method: String
    internal let developerWa: String
    internal let channel: String
    internal let platform: String
    internal let paymentChannel: String
    internal let paymentReturnUrl: String?
    internal let userWa: String
    internal let guestUID: String?
    internal let oemID: String?
    internal let metadata: String?
    internal let reference: String?
    
    internal enum CodingKeys: String, CodingKey {
        case origin = "origin"
        case domain = "domain"
        case price = "price.value"
        case priceCurrency = "price.currency"
        case product = "product"
        case type = "type"
        case method = "method"
        case developerWa = "wallets.developer"
        case channel = "channel"
        case platform = "platform"
        case paymentChannel = "payment.channel"
        case paymentReturnUrl = "payment.return_url"
        case userWa = "wallets.user"
        case guestUID = "entity.guest_id"
        case oemID = "entity.oemid"
        case metadata = "metadata"
        case reference = "reference"
    }
    
    // Review static credit_card use as method
    internal static func fromParameters(parameters: TransactionParameters) -> Result<CreateAdyenTransactionRaw, TransactionError> {
        // normalizes the price to adjust to different time zone price syntaxes
        let normalizedPrice = parameters.value.replacingOccurrences(of: ",", with: ".")
        
        if let method = parameters.method, let bundleID = Bundle.main.bundleIdentifier {
            return .success(
                CreateAdyenTransactionRaw(
                    origin: "BDS", domain: parameters.domain, price: normalizedPrice, priceCurrency: parameters.currency,
                    product: parameters.product, type: "INAPP", method: method, developerWa: parameters.developerWa, channel: "IOS", platform: "IOS", paymentChannel: "IOS", paymentReturnUrl: "\(bundleID).iap://api.blockchainds.com/broker", userWa: parameters.userWa, guestUID: parameters.guestUID, oemID: parameters.oemID, metadata: parameters.metadata, reference: parameters.reference
                )
            )
        } else { return .failure(.failed()) }
    }
    
    internal func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
}

internal struct CreateAdyenTransactionResponseRaw: Codable {
    
    internal let uuid: String
    internal let status: TransactionStatus
    internal let reference: String?
    internal let hash: String?
    internal let session: CreateAdyenTransactionResponseSessionRaw
    
    internal enum CodingKeys: String, CodingKey {
        case uuid = "uid"
        case status = "status"
        case reference = "reference"
        case hash = "hash"
        case session = "session"
    }
}

internal struct CreateAdyenTransactionResponseSessionRaw: Codable {
    
    internal let sessionID: String
    internal let sessionData: String
    
    internal enum CodingKeys: String, CodingKey {
        case sessionID = "id"
        case sessionData = "sessionData"
    }
    
}
