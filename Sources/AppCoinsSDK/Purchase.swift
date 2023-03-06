//
//  Purchase.swift
//  appcoins-sdk
//
//  Created by aptoide on 01/03/2023.
//

import Foundation

public class Purchase: Hashable {
    
    private let itemType: String  // ITEM_TYPE_INAPP or ITEM_TYPE_SUBS
    private let orderId: String
    private let packageName: String
    private let sku: String
    private let purchaseTime: Int64
    private let purchaseState: Int
    private let developerPayload: String
    private let token: String
    private let originalJson: String
    private let signature: Data
    private let isAutoRenewing: Bool
    
    public init(orderId: String, itemType: String, originalJson: String, signature: Data,
                purchaseTime: Int64, purchaseState: Int, developerPayload: String, token: String,
                packageName: String, sku: String, isAutoRenewing: Bool) {
        self.itemType = itemType
        self.orderId = orderId
        self.packageName = packageName
        self.sku = sku
        self.purchaseTime = purchaseTime
        self.purchaseState = purchaseState
        self.developerPayload = developerPayload
        self.token = token
        self.originalJson = originalJson
        self.signature = signature
        self.isAutoRenewing = isAutoRenewing
    }
    
    public func getItemType() -> String {
        return itemType
    }
    
    public func getOrderId() -> String {
        return orderId
    }
    
    public func getPackageName() -> String {
        return packageName
    }
    
    public func getSku() -> String {
        return sku
    }
    
    public func getPurchaseTime() -> Int64 {
        return purchaseTime
    }
    
    public func getPurchaseState() -> Int {
        return purchaseState
    }
    
    public func getDeveloperPayload() -> String {
        return developerPayload
    }
    
    public func getToken() -> String {
        return token
    }
    
    public func getOriginalJson() -> String {
        return originalJson
    }
    
    public func getSignature() -> Data {
        return signature
    }
    
    public func getIsAutoRenewing() -> Bool {
        return isAutoRenewing
    }
    
    public static func == (lhs: Purchase, rhs: Purchase) -> Bool {
        if lhs.getItemType() == rhs.getItemType() &&
            lhs.getOrderId() == rhs.getOrderId() &&
            lhs.getPackageName() == rhs.getPackageName() &&
            lhs.getSku() == rhs.getSku() &&
            lhs.getPurchaseTime() == rhs.getPurchaseTime() &&
            lhs.getPurchaseState() == rhs.getPurchaseState() &&
            lhs.getDeveloperPayload() == rhs.getDeveloperPayload() &&
            lhs.getToken() == rhs.getToken() &&
            lhs.getOriginalJson() == rhs.getOriginalJson() &&
            lhs.getSignature() == rhs.getSignature() &&
            lhs.getIsAutoRenewing() == rhs.getIsAutoRenewing() {
            return true
        }
        return false
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(itemType)
        hasher.combine(orderId)
        hasher.combine(packageName)
        hasher.combine(sku)
        hasher.combine(purchaseTime)
        hasher.combine(purchaseState)
        hasher.combine(developerPayload)
        hasher.combine(token)
        hasher.combine(originalJson)
        hasher.combine(signature)
        hasher.combine(isAutoRenewing)
    }
}
