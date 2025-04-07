//
//  SDKRepository.swift
//
//
//  Created by Graciano Caldeira on 20/02/2025.
//

import Foundation

internal class SDKRepository: SDKRepositoryProtocol {
    
    private let userPreferencesLocalService: UserPreferencesLocalService = UserPreferencesLocalClient()
    
    private var ExternalNavigationCache: Cache<String, ExternalNavigation> = Cache<String, ExternalNavigation>.shared(cacheName: "ExternalNavigation")
    
    internal func isDefault() -> Bool? {
        guard let isSDKDefault = userPreferencesLocalService.isSDKDefault() else { return nil }
        return isSDKDefault == "true" ? true : false
    }
    
    internal func setSDKDefault(value: Bool) {
        let setValue = value ? "true" : "false"
        userPreferencesLocalService.setSDKDefault(value: setValue)
    }
    
    internal func setExternalNavigation(externalNavigation: ExternalNavigation) {
        ExternalNavigationCache.setValue(
            externalNavigation,
            forKey: "ExternalNavigation",
            storageOption: .disk(ttl: 3153600000)
        )
    }
    
    internal func getExternalNavigation() -> ExternalNavigation? {
        return ExternalNavigationCache.getValue(forKey: "ExternalNavigation")
    }
}
