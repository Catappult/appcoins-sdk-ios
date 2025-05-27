//
//  PurchaseIntent.swift
//
//
//  Created by aptoide on 17/04/2025.
//

import Foundation

public struct PurchaseIntent: Sendable, Identifiable, Codable {
    
    public let id: UUID
    public let product: Product
    public let timestamp: Date
    private let discountPolicy: String?
    private let oemID: String?
    
    internal init(product: Product, discountPolicy: String? = nil, oemID: String? = nil) {
        self.id = UUID()
        self.product = product
        self.timestamp = Date()
        self.discountPolicy = discountPolicy
        self.oemID = oemID
    }
    
    /// Approve and *actually* perform the purchase.
    public func confirm(domain: String = (Bundle.main.bundleIdentifier ?? ""), payload: String? = nil, orderID: String = String(Date.timeIntervalSinceReferenceDate)) async -> PurchaseResult {
        PurchaseIntentManager.shared.unset()
        PurchaseIntentManager.shared.loadFromDisk()
        return await product.indirectPurchase(domain: domain, payload: payload, orderID: orderID, discountPolicy: discountPolicy, oemID: oemID)
    }
    
    /// Reject the purchase intent.
    public func reject() {
        PurchaseIntentManager.shared.unset()
    }
}
