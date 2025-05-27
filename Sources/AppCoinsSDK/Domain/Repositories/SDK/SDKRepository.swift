//
//  SDKRepository.swift
//
//
//  Created by Graciano Caldeira on 20/02/2025.
//

import Foundation

internal class SDKRepository: SDKRepositoryProtocol {
    
    private let userPreferencesLocalService: UserPreferencesLocalService = UserPreferencesLocalClient()
    private let purchaseIntentService: PurchaseIntentService = PurchaseIntentClient()
    
    internal func isDefault() -> Bool? {
        guard let isSDKDefault = userPreferencesLocalService.isSDKDefault() else { return nil }
        return isSDKDefault == "true" ? true : false
    }
    
    internal func setSDKDefault(value: Bool) {
        let setValue = value ? "true" : "false"
        userPreferencesLocalService.setSDKDefault(value: setValue)
    }
    
    internal func persistPurchaseIntent(intent: PurchaseIntent) {
        purchaseIntentService.persist(intent: intent)
    }
    
    internal func fetchPurchaseIntent() -> PurchaseIntent? {
        let intent = purchaseIntentService.fetch()
        return intent
    }
    
    internal func removePurchaseIntent() {
        purchaseIntentService.remove()
    }
}
