//
//  SDKRepository.swift
//
//
//  Created by Graciano Caldeira on 20/02/2025.
//

import Foundation

internal class SDKRepository: SDKRepositoryProtocol {
    
    private let userPreferencesLocalService: UserPreferencesLocalService = UserPreferencesLocalClient()
    
    internal func isDefault() -> Bool? {
        guard let isSDKDefault = userPreferencesLocalService.isSDKDefault() else { return nil }
        return isSDKDefault == "true" ? true : false
    }
    
    internal func setSDKDefault(value: Bool) {
        let setValue = value ? "true" : "false"
        userPreferencesLocalService.setSDKDefault(value: setValue)
    }
}
