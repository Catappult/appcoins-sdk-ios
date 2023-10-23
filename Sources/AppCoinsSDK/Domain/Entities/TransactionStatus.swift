//
//  TransactionStatus.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import Foundation

internal enum TransactionStatus: String, Codable {
    
    internal init(from decoder: Decoder) throws {
        self = try TransactionStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .UNKNOWN
    }
    
    case PENDING = "PENDING"
    case PENDING_SERVICE_AUTHORIZATION = "PENDING_SERVICE_AUTHORIZATION"
    case PROCESSING = "PROCESSING"
    case COMPLETED = "COMPLETED"
    case PENDING_USER_PAYMENT = "PENDING_USER_PAYMENT"
    case INVALID_TRANSACTION = "INVALID_TRANSACTION"
    case FAILED = "FAILED"
    case CANCELED = "CANCELED"
    case FRAUD = "FRAUD"
    case SETTLED = "SETTLED"
    case UNKNOWN
}
