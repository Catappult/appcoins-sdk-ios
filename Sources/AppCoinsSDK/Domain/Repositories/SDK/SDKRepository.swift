//
//  SDKRepository.swift
//

import Foundation

internal class SDKRepository: SDKRepositoryProtocol {

    private let userPreferencesLocalService: UserPreferencesLocalService = UserPreferencesLocalClient()
    private var didInitializeSDK: Bool = false

    internal func getSDKAvailabilityMode() -> SDKAvailabilityMode {
        guard let raw = userPreferencesLocalService.getSDKAvailabilityMode(),
              let mode = SDKAvailabilityMode(rawValue: raw) else {
            return .automatic
        }
        return mode
    }

    internal func setSDKAvailabilityMode(mode: SDKAvailabilityMode) {
        userPreferencesLocalService.setSDKAvailabilityMode(mode: mode.rawValue)
    }

    internal func setSDKInitialized() { didInitializeSDK = true }
    internal func isSDKInitialized() -> Bool { return didInitializeSDK }
}
