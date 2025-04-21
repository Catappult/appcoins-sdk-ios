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
    
    public init(product: Product) {
        self.id = UUID()
        self.product = product
        self.timestamp = Date()
    }
    
    /// Approve and *actually* perform the purchase.
    public func purchase(domain: String = (Bundle.main.bundleIdentifier ?? ""), payload: String? = nil, orderID: String = String(Date.timeIntervalSinceReferenceDate)) async -> PurchaseResult {
        PurchaseIntentManager.shared.unset()
        return await product.purchase(domain: domain, payload: payload, orderID: orderID)
    }
}
