//
//  SDKRepository.swift
//
//
//  Created by Graciano Caldeira on 20/02/2025.
//

import Foundation

internal class SDKRepository: SDKRepositoryProtocol {
    
    private let userPreferencesLocalService: UserPreferencesLocalService = UserPreferencesLocalClient()
    
    internal func isDefault() -> Bool { return (userPreferencesLocalService.isSDKDefault() == "true") ? true : false }
    
    internal func toggleSDKDefault() {
        let currentValue = userPreferencesLocalService.isSDKDefault()
        let newValue = (currentValue == "true") ? "false" : "true"
        userPreferencesLocalService.setSDKDefault(value: newValue)
    }
}
