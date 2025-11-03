//
//  UserPreferencesLocalService.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import Foundation

internal protocol UserPreferencesLocalService {
    func isSDKDefault() -> String?
    func setSDKDefault(value: String)
    
    func getDefaultStorefrontLocale() -> String?
    func setSDKDefaultStorefrontLocale(locale: String)
    
    func getDefaultStorefrontMarketplace() -> String?
    func setSDKDefaultStorefrontMarketplace(marketplace: String)
    
    func setSDKInitialized()
    func isSDKInitialized() -> Bool
}
