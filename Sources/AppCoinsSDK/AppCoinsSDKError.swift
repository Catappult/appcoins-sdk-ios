//
//  File.swift
//  
//
//  Created by aptoide on 22/05/2023.
//

import Foundation

public enum AppCoinsSDKError: Error {
    case networkError // Network related errors
    case systemError // Internal APPC system errors
    case notEntitled // The host app does not have proper entitlements configured
    case productUnavailable // The product is not available
    case purchaseNotAllowed // The user was not allowed to perform the purchase
    case unknown // Other errors
}
