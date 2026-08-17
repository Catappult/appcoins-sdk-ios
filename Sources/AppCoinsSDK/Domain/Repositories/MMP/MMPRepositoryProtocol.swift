//
//  AttributionRepositoryProtocol.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal protocol MMPRepositoryProtocol {
    func getAttribution()
    func getGuestUID() -> String?
    func getOEMID() -> String?
    func startSession()
    func sendPurchaseEvent(sku: String, orderID: String, purchaseAmount: String, paymentMethod: String)
}
