//
//  File.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import Foundation

struct CreateAdyenTransactionRaw: Codable {
    
    let origin: String?
    let domain: String
    let price: String?
    let priceCurrency: String
    let product: String?
    let type: String
    let method: String
    let developerWa: String
    let paymentChannel: String
    let paymentReturnUrl: String?
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
        case method = "method"
        case developerWa = "wallets.developer"
        case paymentChannel = "payment.channel"
        case paymentReturnUrl = "payment.return_url"
        case userWa = "wallets.user"
        case metadata = "metadata"
        case reference = "reference"
    }
    
    // Review static credit_card use as method
    static func fromDictionary(dictionary: [String : String]) -> Result<CreateAdyenTransactionRaw, TransactionError> {
        // normalizes the price to adjust to different time zone price syntaxes
        let normalizedPrice = (dictionary["value"] ?? "0.0").replacingOccurrences(of: ",", with: ".")
        
        var metadata: String?
        if dictionary["metadata"] == "" { metadata = nil } else { metadata = dictionary["metadata"] }
        var reference: String?
        if dictionary["reference"] == "" { reference = nil } else { reference = dictionary["reference"] }
        
        if let domain = dictionary["domain"], let priceCurrency = dictionary["currency"], let method = dictionary["method"], let developerWa = dictionary["developerWa"], let userWa = dictionary["userWa"], let bundleID = Bundle.main.bundleIdentifier {
            return .success(
                CreateAdyenTransactionRaw(
                    origin: "BDS", domain: domain, price: normalizedPrice, priceCurrency: priceCurrency,
                    product: dictionary["product"], type: "INAPP", method: method, developerWa: developerWa, paymentChannel: "IOS", paymentReturnUrl: "\(bundleID).iap://api.blockchainds.com/broker", userWa: userWa, metadata: metadata, reference: reference
                )
            )
        } else { return .failure(.failed()) }
    }
    
    func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
}

struct CreateAdyenTransactionResponseRaw: Codable {
    
    let uuid: String
    let status: TransactionStatus
    let reference: String?
    let hash: String?
    let session: CreateAdyenTransactionResponseSessionRaw
    
    enum CodingKeys: String, CodingKey {
        case uuid = "uid"
        case status = "status"
        case reference = "reference"
        case hash = "hash"
        case session = "session"
    }
    
}

struct CreateAdyenTransactionResponseSessionRaw: Codable {
    
    let sessionID: String
    let sessionData: String
    
    enum CodingKeys: String, CodingKey {
        case sessionID = "id"
        case sessionData = "sessionData"
    }
    
}
