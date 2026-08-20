//
//  MMPPendingPurchaseEvent.swift
//
//
//  Created by aptoide on 17/08/2026.
//

import Foundation

internal struct MMPPendingPurchaseEvent: Codable {
    internal let packageName: String
    internal let oemID: String
    internal let guestUID: String
    internal let sku: String
    internal let orderID: String
    internal let purchaseAmount: String
    internal let paymentMethod: String
    internal let timestamp: Int
    internal let vercode: String
    internal let utmSource: String?
    internal let utmMedium: String?
    internal let utmCampaign: String?
    internal let utmContent: String?
    internal let utmTerm: String?
}
