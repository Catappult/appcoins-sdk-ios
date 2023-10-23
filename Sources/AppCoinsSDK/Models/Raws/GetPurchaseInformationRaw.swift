//
//  GetPurchaseInformationRaw.swift
//  
//
//  Created by aptoide on 23/05/2023.
//

import Foundation

internal struct GetPurchasesRaw: Codable {
    
    internal let items: [PurchaseInformationRaw]
    
    internal enum CodingKeys: String, CodingKey {
        case items = "items"
    }
}

internal struct PurchaseInformationRaw: Codable {
    
    internal let uid: String
    internal let sku: String
    internal let state: String
    internal let order_uid: String
    internal let payload: String?
    internal let created: String
    internal let verification: PurchaseVerificationRaw
    
    internal enum CodingKeys: String, CodingKey {
        case uid = "uid"
        case sku = "sku"
        case state = "state"
        case order_uid = "order_uid"
        case payload = "payload"
        case created = "created"
        case verification = "verification"
    }
}

internal struct PurchaseVerificationRaw: Codable {
    
    internal let type: String
    internal let data: String
    internal let signature: String
    
    internal enum CodingKeys: String, CodingKey {
        case type = "type"
        case data = "data"
        case signature = "signature"
    }
    
}
