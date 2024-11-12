//
//  AptoideServiceErrors.swift
//
//
//  Created by aptoide on 18/05/2023.
//

import Foundation

internal enum AptoideIOSServiceError: Error {
    case failed(message: String, description: String, request: DebugRequestInfo? = nil)
    case noInternet(message: String, description: String, request: DebugRequestInfo? = nil)
}
