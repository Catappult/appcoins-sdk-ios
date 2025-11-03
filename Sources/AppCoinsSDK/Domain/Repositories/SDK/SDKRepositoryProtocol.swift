//
//  SDKRepositoryProtocol.swift
//  
//
//  Created by Graciano Caldeira on 20/02/2025.
//

import Foundation

internal protocol SDKRepositoryProtocol {
    
    func isDefault() -> Bool?
    func setSDKDefault(value: Bool)
    
    func getDefaultStorefrontLocale() -> String?
    func setSDKDefaultStorefrontLocale(locale: String)
    
    func getDefaultStorefrontMarketplace() -> String?
    func setSDKDefaultStorefrontMarketplace(marketplace: String)
    
    func persistPurchaseIntent(intent: PurchaseIntent)
    func fetchPurchaseIntent() -> PurchaseIntent?
    func removePurchaseIntent()
    
}
