//
//  UserPreferencesLocalClient.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import Foundation

internal class UserPreferencesLocalClient: UserPreferencesLocalService {
    
    internal func isSDKDefault() -> String? {
        let isSDKDefault: String = Utils.readFromPreferences(key: "is-sdk-default")
        return isSDKDefault == "" ? nil : isSDKDefault
    }
    
    internal func setSDKDefault(value: String) {
        try? Utils.writeToPreferences(key: "is-sdk-default", value: value)
    }
    
    func getDefaultStorefrontLocale() -> String? {
        let defaultStorefrontLocale: String = Utils.readFromPreferences(key: "sdk-default-storefront-locale")
        return defaultStorefrontLocale == "" ? nil : defaultStorefrontLocale
    }
    
    func setSDKDefaultStorefrontLocale(locale: String) {
        try? Utils.writeToPreferences(key: "sdk-default-storefront-locale", value: locale)
    }
    
    func getDefaultStorefrontMarketplace() -> String? {
        let defaultStorefrontMarketplace: String = Utils.readFromPreferences(key: "sdk-default-storefront-marketplace")
        return defaultStorefrontMarketplace == "" ? nil : defaultStorefrontMarketplace
    }
    
    func setSDKDefaultStorefrontMarketplace(marketplace: String) {
        try? Utils.writeToPreferences(key: "sdk-default-storefront-marketplace", value: marketplace)
    }
}
