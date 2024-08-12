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
    internal let data: PurchaseVerificationDataRaw
    internal let originalData: String
    internal let signature: String
    
    internal enum CodingKeys: String, CodingKey {
        case type = "type"
        case data = "data"
        case signature = "signature"
    }
    
    // Custom decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        
        // Decode data as string first to preserve the original string
        originalData = try container.decode(String.self, forKey: .data)
        
        // Decode the JSON string into a PurchaseVerificationDataRaw object
        if let jsonData = originalData.data(using: .utf8) {
            data = try JSONDecoder().decode(PurchaseVerificationDataRaw.self, from: jsonData)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .data, in: container, debugDescription: "Data string is not valid JSON")
        }
        
        signature = try container.decode(String.self, forKey: .signature)
    }
}

internal struct PurchaseVerificationDataRaw: Codable {
    
    internal let orderId: String
    internal let packageName: String
    internal let productId: String
    internal let purchaseTime: Int
    internal let purchaseToken: String
    internal let purchaseState: Int
    internal let developerPayload: String
    
    internal enum CodingKeys: String, CodingKey {
        case orderId = "orderId"
        case packageName = "packageName"
        case productId = "productId"
        case purchaseTime = "purchaseTime"
        case purchaseToken = "purchaseToken"
        case purchaseState = "purchaseState"
        case developerPayload = "developerPayload"
    }
}
