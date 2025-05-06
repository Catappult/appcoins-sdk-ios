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
        case responseCode = "responseCode"
        case purchaseData = "purchaseData"
        case dataSignature = "dataSignature"
        case orderReference = "orderReference"
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
            case orderId = "orderId"
            case packageName = "packageName"
            case productId = "productId"
            case purchaseTime = "purchaseTime"
            case purchaseToken = "purchaseToken"
            case purchaseState = "purchaseState"
            case developerPayload = "developerPayload"
            case productType = "productType"
            case isAutoRenewing = "isAutoRenewing"
        }
    }
}
