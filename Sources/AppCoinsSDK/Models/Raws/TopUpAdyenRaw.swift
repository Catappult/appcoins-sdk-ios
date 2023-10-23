//
//  TopUpAdyenRaw.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import Foundation

internal struct TopUpAdyenRaw: Codable {
    
    internal let origin: String?
    internal let domain: String
    internal let price: String?
    internal let priceCurrency: String
    internal let type: String
    internal let method: String
    internal let channel: String
    internal let paymentReturnUrl: String?
    
    internal enum CodingKeys: String, CodingKey {
        case origin = "origin"
        case domain = "domain"
        case price = "price.value"
        case priceCurrency = "price.currency"
        case type = "type"
        case method = "method"
        case channel = "channel"
        case paymentReturnUrl = "payment.return_url"
    }
    
    internal static func build(price: String, priceCurrency: String, method: String) -> TopUpAdyenRaw {
        // normalizes the price to adjust to different time zone price syntaxes
        let normalizedPrice = price.replacingOccurrences(of: ",", with: ".")
        
        return TopUpAdyenRaw(origin: "BDS", domain: BuildConfiguration.appcDomain, price: normalizedPrice, priceCurrency: priceCurrency, type: "TOPUP", method: method, channel: "iOS", paymentReturnUrl: "com.aptoide.appcoins-wallet.iap://api.blockchainds.com/broker")
    }
    
    internal func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
}

internal struct TopUpAdyenResponseRaw: Codable {
    
    internal let uuid: String
    internal let status: TransactionStatus
    internal let reference: String?
    internal let hash: String?
    internal let session: TopUpAdyenResponseSessionRaw
    
    internal enum CodingKeys: String, CodingKey {
        case uuid = "uid"
        case status = "status"
        case reference = "reference"
        case hash = "hash"
        case session = "session"
    }
    
}

internal struct TopUpAdyenResponseSessionRaw: Codable {
    
    internal let sessionID: String
    internal let sessionData: String
    
    internal enum CodingKeys: String, CodingKey {
        case sessionID = "id"
        case sessionData = "sessionData"
    }
    
}
