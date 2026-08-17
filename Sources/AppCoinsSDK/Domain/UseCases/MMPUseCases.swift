//
//  AttributionUseCases.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal class MMPUseCases {

    internal static let shared: MMPUseCases = MMPUseCases()
    private let repository: MMPRepositoryProtocol

    private init(repository: MMPRepositoryProtocol = MMPRepository()) {
        self.repository = repository
    }

    internal func getAttribution() { repository.getAttribution() }

    internal func getGuestUID() -> String? { return repository.getGuestUID() }

    internal func getOEMID() -> String? { return repository.getOEMID() }

    internal func startSession() { repository.startSession() }

    internal func sendPurchaseEvent(sku: String, orderID: String, purchaseAmount: String, paymentMethod: String) {
        repository.sendPurchaseEvent(sku: sku, orderID: orderID, purchaseAmount: purchaseAmount, paymentMethod: paymentMethod)
    }
}
