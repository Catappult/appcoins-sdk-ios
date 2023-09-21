//
//  File.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import Foundation

struct TopUpAdyenRaw: Codable {
    
    let origin: String?
    let domain: String
    let price: String?
    let priceCurrency: String
    let type: String
    let method: String
    let channel: String
    let paymentReturnUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case origin = "origin"
        case domain = "domain"
        case price = "price.value"
        case priceCurrency = "price.currency"
        case type = "type"
        case method = "method"
        case channel = "channel"
        case paymentReturnUrl = "payment.return_url"
    }
    
    static func build(price: String, priceCurrency: String, method: String) -> TopUpAdyenRaw {
        // normalizes the price to adjust to different time zone price syntaxes
        let normalizedPrice = price.replacingOccurrences(of: ",", with: ".")
        
        return TopUpAdyenRaw(origin: "BDS", domain: BuildConfiguration.appcDomain, price: normalizedPrice, priceCurrency: priceCurrency, type: "TOPUP", method: method, channel: "iOS", paymentReturnUrl: "com.aptoide.appcoins-wallet.iap://api.blockchainds.com/broker")
    }
    
    func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
}

struct TopUpAdyenResponseRaw: Codable {
    
    let uuid: String
    let status: TransactionStatus
    let reference: String?
    let hash: String?
    let session: TopUpAdyenResponseSessionRaw
    
    enum CodingKeys: String, CodingKey {
        case uuid = "uid"
        case status = "status"
        case reference = "reference"
        case hash = "hash"
        case session = "session"
    }
    
}

struct TopUpAdyenResponseSessionRaw: Codable {
    
    let sessionID: String
    let sessionData: String
    
    enum CodingKeys: String, CodingKey {
        case sessionID = "id"
        case sessionData = "sessionData"
    }
    
}
