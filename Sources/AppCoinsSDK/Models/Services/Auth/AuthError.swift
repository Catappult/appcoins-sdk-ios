//
//  AuthError.swift
//  
//
//  Created by aptoide on 12/12/2024.
//

import Foundation

internal enum AuthError: Error {
    case failed(message: String, description: String, request: DebugRequestInfo? = nil)
    case noInternet(message: String, description: String, request: DebugRequestInfo? = nil)
}
