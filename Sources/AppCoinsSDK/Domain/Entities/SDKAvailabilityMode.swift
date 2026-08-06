//
//  SDKAvailabilityMode.swift
//  AppCoinsSDK
//

import Foundation

internal enum SDKAvailabilityMode: String {
    case appCoins = "appcoins"
    case apple = "apple"
    case automatic = "automatic"

    var displayName: String {
        switch self {
        case .appCoins: return "AppCoins"
        case .apple: return "Apple"
        case .automatic: return "Automatic"
        }
    }
}
