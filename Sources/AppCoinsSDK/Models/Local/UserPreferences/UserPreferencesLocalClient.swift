//
//  UserPreferencesLocalClient.swift
//

import Foundation

internal class UserPreferencesLocalClient: UserPreferencesLocalService {

    func getSDKAvailabilityMode() -> String? {
        let value: String = Utils.readFromPreferences(key: "sdk-availability-mode")
        return value == "" ? nil : value
    }

    func setSDKAvailabilityMode(mode: String) {
        try? Utils.writeToPreferences(key: "sdk-availability-mode", value: mode)
    }
}
