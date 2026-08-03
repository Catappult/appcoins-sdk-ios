//
//  SDKRepositoryProtocol.swift
//

import Foundation

internal protocol SDKRepositoryProtocol {

    func getSDKAvailabilityMode() -> SDKAvailabilityMode
    func setSDKAvailabilityMode(mode: SDKAvailabilityMode)

    func setSDKInitialized()
    func isSDKInitialized() -> Bool
}
