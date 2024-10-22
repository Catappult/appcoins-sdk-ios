//
//  File.swift
//  
//
//  Created by aptoide on 12/07/2024.
//

import Foundation

internal enum APPCServiceError: Error {
    case failed(message: String, description: String, request: DebugRequestInfo? = nil)
    case noInternet(message: String, description: String, request: DebugRequestInfo? = nil)
}
