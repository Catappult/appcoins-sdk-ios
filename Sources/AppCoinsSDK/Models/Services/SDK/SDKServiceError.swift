//
//  SDKServiceError.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/01/2026.
//

internal enum SDKServiceError: Error {
    case failed(message: String, description: String, request: DebugRequestInfo? = nil)
    case noInternet(message: String, description: String, request: DebugRequestInfo? = nil)
}
