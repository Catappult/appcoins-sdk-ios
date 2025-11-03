//
//  SDKUseCases.swift
//
//
//  Created by Graciano Caldeira on 20/02/2025.
//

import Foundation

internal class SDKUseCases {
    
    internal static let shared = SDKUseCases()
    private var repository: SDKRepositoryProtocol
    
    private init(repository: SDKRepositoryProtocol = SDKRepository()) { self.repository = repository }
    
    internal func isDefault() -> Bool? { self.repository.isDefault() }
    internal func setSDKDefault(value: Bool) { self.repository.setSDKDefault(value: value) }
    
    internal func getDefaultStorefrontLocale() -> String? { self.repository.getDefaultStorefrontLocale() }
    internal func setSDKDefaultStorefrontLocale(locale: String) { self.repository.setSDKDefaultStorefrontLocale(locale: locale) }

    internal func getDefaultStorefrontMarketplace() -> String? { self.repository.getDefaultStorefrontMarketplace() }
    internal func setSDKDefaultStorefrontMarketplace(marketplace: String) { self.repository.setSDKDefaultStorefrontMarketplace(marketplace: marketplace) }
    
    internal func persistPurchaseIntent(intent: PurchaseIntent) { repository.persistPurchaseIntent(intent: intent) }
    internal func fetchPurchaseIntent() -> PurchaseIntent? { return repository.fetchPurchaseIntent() }
    internal func removePurchaseIntent() { repository.removePurchaseIntent() }
    
    internal func setSDKInitialized() { repository.setSDKInitialized() }
    internal func isSDKInitialized() -> Bool { repository.isSDKInitialized() }
}
