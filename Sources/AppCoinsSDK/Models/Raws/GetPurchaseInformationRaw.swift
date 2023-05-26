//
//  File.swift
//  
//
//  Created by aptoide on 23/05/2023.
//

import Foundation

struct GetPurchasesRaw: Codable {
    
    let items: [PurchaseInformationRaw]
    
    enum CodingKeys: String, CodingKey {
        case items = "items"
    }
}

struct PurchaseInformationRaw: Codable {
    
    let uid: String
    let sku: String
    let state: String
    let order_uid: String
    let payload: String
    let created: String
    let verification: PurchaseVerificationRaw
    
    enum CodingKeys: String, CodingKey {
        case uid = "uid"
        case sku = "sku"
        case state = "state"
        case order_uid = "order_uid"
        case payload = "payload"
        case created = "created"
        case verification = "verification"
    }
}

struct PurchaseVerificationRaw: Codable {
    
    let type: String
    let data: String
    let signature: String
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case data = "data"
        case signature = "signature"
    }
    
}
