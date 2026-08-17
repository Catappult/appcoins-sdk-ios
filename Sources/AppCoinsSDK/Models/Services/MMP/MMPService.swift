//
//  AttributionService.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal protocol MMPService {
    func getAttribution(bundleID: String, result: @escaping (Result<AttributionRaw, Error>) -> Void)
    func sendUserSession(
        bundleID: String,
        oemID: String,
        guestUID: String,
        sessionID: String,
        sessionDuration: Int,
        utmSource: String?,
        utmMedium: String?,
        utmCampaign: String?,
        utmContent: String?,
        utmTerm: String?,
        result: @escaping (Result<Void, Error>) -> Void
    )
    func sendPurchaseEvent(
        bundleID: String,
        oemID: String,
        guestUID: String,
        sku: String,
        orderID: String,
        purchaseAmount: String,
        paymentMethod: String,
        utmSource: String?,
        utmMedium: String?,
        utmCampaign: String?,
        utmContent: String?,
        utmTerm: String?,
        result: @escaping (Result<Void, Error>) -> Void
    )
}
