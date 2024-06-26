//
//  TransactionError.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal enum TransactionError: Error {
    case failed(description: String? = nil)
    case noInternet
    case timeOut
    case general
    case noBillingAgreement
}
