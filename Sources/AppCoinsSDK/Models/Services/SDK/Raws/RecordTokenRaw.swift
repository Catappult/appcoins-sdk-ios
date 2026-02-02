//
//  RecordTokenRaw.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/01/2026.
//

import Foundation
@_implementationOnly import MarketplaceKit
@_implementationOnly import StoreKit

@available(iOS 15.0, *)
internal struct RecordTokenRaw: Codable {
    internal let token: RecordTokenRaw.Token
    internal let transaction: RecordTokenRaw.Transaction?
    internal let locale: String?
    
    internal enum CodingKeys: String, CodingKey {
        case token = "token"
        case transaction = "transaction"
        case locale = "locale"
    }
    
    internal static func fromParameters(
        token: ExternalPurchaseToken,
        transactionUID: String? = nil,
        completion: @escaping (RecordTokenRaw) -> Void
    ) {
        Task {
            var locale: String? = nil
            if let defaultLocale = AppcSDK.configuration.storefront?.locale {
                locale = defaultLocale.code
            } else {
                locale = await Storefront.current?.countryCode
            }
            Utils.log("Reporting External Purchase Token for Locale: \(locale)")

            completion(
                RecordTokenRaw(
                    token: RecordTokenRaw.Token.fromParameters(token: token),
                    transaction: transactionUID.flatMap {
                        RecordTokenRaw.Transaction.fromParameters(transactionUID: $0)
                    },
                    locale: locale
                )
            )
        }
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
