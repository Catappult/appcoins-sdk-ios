//
//  UserPreferencesLocalService.swift
//

import Foundation

internal protocol UserPreferencesLocalService {
    func getSDKAvailabilityMode() -> String?
    func setSDKAvailabilityMode(mode: String)
}
