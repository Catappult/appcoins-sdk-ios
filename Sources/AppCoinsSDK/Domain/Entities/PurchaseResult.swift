//
//  PurchaseResult.swift
//
//
//  Created by aptoide on 24/05/2023.
//

import Foundation

// Internal — used for the notification mechanism between PurchaseViewModel and Product.purchase()
internal enum PurchaseResult {
    case success(verificationResult: VerificationResult<Transaction>)
    case pending
    case userCancelled
    case failed(error: AppCoinsSDKError)
}

public enum VerificationResult<SignedType> {
    case verified(SignedType)
    case unverified(SignedType, AppCoinsSDKError)
}
