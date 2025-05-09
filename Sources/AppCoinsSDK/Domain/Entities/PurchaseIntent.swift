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
    private let platform: String?
    private let oemID: String?
    
    public init(product: Product, platform: String? = nil, oemID: String? = nil) {
        self.id = UUID()
        self.product = product
        self.timestamp = Date()
        self.platform = platform
        self.oemID = oemID
    }
    
    /// Approve and *actually* perform the purchase.
    public func confirm(domain: String = (Bundle.main.bundleIdentifier ?? ""), payload: String? = nil, orderID: String = String(Date.timeIntervalSinceReferenceDate)) async -> PurchaseResult {
        PurchaseIntentManager.shared.unset()
        PurchaseIntentManager.shared.loadFromDisk()
        return await product.indirectPurchase(domain: domain, payload: payload, orderID: orderID, platform: platform, oemID: oemID)
    }
    
    /// Reject the purchase intent.
    public func reject() {
        PurchaseIntentManager.shared.unset()
    }
}
