//
//  ProductServiceError.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal enum ProductServiceError: Error {
    case failed
    case noInternet
    case purchaseVerificationFailed
}
