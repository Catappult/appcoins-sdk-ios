//
//  SDKRepository.swift
//
//
//  Created by Graciano Caldeira on 20/02/2025.
//

import Foundation

internal class SDKRepository: SDKRepositoryProtocol {
    
    private let userPreferencesLocalService: UserPreferencesLocalService = UserPreferencesLocalClient()
    
    internal func isDefault() -> Bool { return (userPreferencesLocalService.getIsSDKDefault() == "true") ? true : false }
    
    internal func setSDKDefault() {
        let currentValue = userPreferencesLocalService.getIsSDKDefault()
        let newValue = (currentValue == "true") ? "false" : "true"
        userPreferencesLocalService.setIsSDKDefault(value: newValue)
    }
}
