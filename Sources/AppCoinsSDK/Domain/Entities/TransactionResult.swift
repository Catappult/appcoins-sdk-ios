//
//  TransactionResult.swift
//
//
//  Created by aptoide on 24/05/2023.
//

import Foundation

internal enum TransactionResult {
    case success(verificationResult : VerificationResult)
    case pending
    case userCancelled
    case failed(error: AppCoinsSDKError)
}

internal enum VerificationResult {
    case verified(purchase: Purchase)
    case unverified(purchase: Purchase, verificationError: AppCoinsSDKError)
}
