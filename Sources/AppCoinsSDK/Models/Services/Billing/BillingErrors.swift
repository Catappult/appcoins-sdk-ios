//
//  BillingErrors.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal enum BillingError: Error {
    case failed(message: String, description: String, request: DebugRequestInfo? = nil)
    case noInternet(message: String, description: String, request: DebugRequestInfo? = nil)
}
