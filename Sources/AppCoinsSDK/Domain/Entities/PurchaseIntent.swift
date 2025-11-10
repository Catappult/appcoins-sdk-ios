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
    private let discountPolicy: DiscountPolicy?
    private let oemID: String?
    
    internal init(product: Product, discountPolicy: DiscountPolicy? = nil, oemID: String? = nil) {
        self.id = UUID()
        self.product = product
        self.timestamp = Date()
        self.discountPolicy = discountPolicy
        self.oemID = oemID
    }
    
    /// Approve and *actually* perform the purchase.
    public func confirm(
        domain: String = (Bundle.main.bundleIdentifier ?? ""),
        payload: String? = nil,
        orderID: String = String(Date.timeIntervalSinceReferenceDate)
    ) async -> PurchaseResult {
        Utils.log(
            "PurchaseIntent.confirm(domain: \(domain), payload: \(payload), orderID: \(orderID)) at PurchaseIntent.swift",
            category: "Lifecycle",
            level: .info
        )
        
        Utils.log("Purchase intent confirmed. Unsetting purchase intent at PurchaseIntent.swift.confirm")
        PurchaseIntentManager.shared.unset()
        
        Utils.log("Loading purchase intent from disk at PurchaseIntent.swift.confirm")
        PurchaseIntentManager.shared.loadFromDisk()
        
        return await product.indirectPurchase(domain: domain, payload: payload, orderID: orderID, discountPolicy: discountPolicy, oemID: oemID)
    }
    
    /// Reject the purchase intent.
    public func reject() {
        Utils.log(
            "PurchaseIntent.reject() at PurchaseIntent.swift",
            category: "Lifecycle",
            level: .info
        )
        
        Utils.log("Purchase intent rejected. Unsetting purchase intent at PurchaseIntent.swift.reject")
        PurchaseIntentManager.shared.unset()
    }
}
