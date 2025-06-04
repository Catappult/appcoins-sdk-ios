//
//  OnPurchaseResultBody.swift
//  
//
//  Created by aptoide on 04/04/2025.
//

import Foundation

internal struct OnPurchaseResultBody: Codable {
    
    internal let responseCode: Int
    internal let purchaseData: PurchaseData
    internal let dataSignature: String
    internal let orderReference: String?
    
    internal enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case purchaseData = "purchase_data"
        case dataSignature = "data_signature"
        case orderReference = "order_reference"
    }
    
    internal struct PurchaseData: Codable {
        
        internal let orderId: String
        internal let packageName: String
        internal let productId: String
        internal let purchaseTime: Int
        internal let purchaseToken: String
        internal let purchaseState: Int
        internal let developerPayload: String
        internal let productType: String
        internal let isAutoRenewing: Bool
        
        internal enum CodingKeys: String, CodingKey {
            case orderId = "order_id"
            case packageName = "package_name"
            case productId = "product_id"
            case purchaseTime = "purchase_time"
            case purchaseToken = "purchase_token"
            case purchaseState = "purchase_state"
            case developerPayload = "developer_payload"
            case productType = "product_type"
            case isAutoRenewing = "is_auto_renewing"
        }
    }
}
