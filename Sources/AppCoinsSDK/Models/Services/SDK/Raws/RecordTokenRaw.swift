//
//  RecordTokenRaw.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/01/2026.
//

import Foundation

internal struct RecordTokenRaw: Codable {
    internal let token: RecordTokenRaw.Token
    internal let transaction: RecordTokenRaw.Transaction?
    
    internal enum CodingKeys: String, CodingKey {
        case token = "token"
        case transaction = "transaction"
    }
    
    internal static func fromParameters(
        token: ExternalPurchaseToken,
        transactionUID: String? = nil
    ) -> RecordTokenRaw {
        return RecordTokenRaw(
            token: RecordTokenRaw.Token.fromParameters(token: token),
            transaction: transactionUID.flatMap {
                UID in RecordTokenRaw.Transaction.fromParameters(transactionUID: UID)
            }
        )
    }
    
    internal struct Token: Codable {
        internal let appAppleId: Int
        internal let bundleId: String
        internal let externalPurchaseId: String
        internal let tokenType: String
        
        internal enum CodingKeys: String, CodingKey {
            case appAppleId = "app_apple_id"
            case bundleId = "bundle_id"
            case externalPurchaseId = "external_purchase_id"
            case tokenType = "token_type"
        }
        
        internal static func fromParameters(token: ExternalPurchaseToken) -> RecordTokenRaw.Token {
            return RecordTokenRaw.Token(
                appAppleId: token.appAppleId,
                bundleId: token.bundleId,
                externalPurchaseId: token.externalPurchaseId,
                tokenType: token.tokenType
            )
        }
    }
    
    internal struct Transaction: Codable {
        internal let transactionUID: String
        
        internal enum CodingKeys: String, CodingKey {
            case transactionUID = "uid"
        }
        
        internal static func fromParameters(transactionUID: String) -> RecordTokenRaw.Transaction {
            return RecordTokenRaw.Transaction(
                transactionUID: transactionUID
            )
        }
    }
}
