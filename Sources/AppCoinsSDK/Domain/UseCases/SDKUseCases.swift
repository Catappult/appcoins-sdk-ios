//
//  SDKUseCases.swift
//

import Foundation

internal class SDKUseCases {

    internal static let shared = SDKUseCases()
    private var repository: SDKRepositoryProtocol

    private init(repository: SDKRepositoryProtocol = SDKRepository()) { self.repository = repository }

    internal func getSDKAvailabilityMode() -> SDKAvailabilityMode { self.repository.getSDKAvailabilityMode() }
    internal func setSDKAvailabilityMode(mode: SDKAvailabilityMode) { self.repository.setSDKAvailabilityMode(mode: mode) }

    internal func setSDKInitialized() { repository.setSDKInitialized() }
    internal func isSDKInitialized() -> Bool { repository.isSDKInitialized() }
}
