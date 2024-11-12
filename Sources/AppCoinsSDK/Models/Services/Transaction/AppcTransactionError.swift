//
//  AppcTransactionError.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal enum AppcTransactionError: Error {
    case failed(message: String, description: String, request: DebugRequestInfo? = nil)
    case noInternet(message: String, description: String, request: DebugRequestInfo? = nil)
}
