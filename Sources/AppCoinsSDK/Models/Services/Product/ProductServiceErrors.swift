//
//  ProductServiceError.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal enum ProductServiceError: Error {
    case failed(message: String, description: String)
    case noInternet(message: String, description: String)
    case purchaseVerificationFailed(message: String, description: String)
}
