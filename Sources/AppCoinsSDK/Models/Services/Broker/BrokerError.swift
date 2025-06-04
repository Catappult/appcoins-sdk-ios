//
//  BrokerError.swift
//  AppCoinsSDK
//
//  Created by aptoide on 02/06/2025.
//

import Foundation

internal enum BrokerError: Error {
    case failed(message: String, description: String, request: DebugRequestInfo? = nil)
    case noInternet(message: String, description: String, request: DebugRequestInfo? = nil)
}
