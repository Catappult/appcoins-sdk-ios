//
//  TransactionError.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal enum TransactionError: Error {
    case failed(message: String, description: String, request: )
    case noInternet(message: String, description: String)
    case timeOut(message: String, description: String)
    case general(message: String, description: String)
    case noBillingAgreement(message: String, description: String)
}
