//
//  RecordTokenRaw.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/01/2026.
//

import Foundation
@_implementationOnly import MarketplaceKit

@available(iOS 26.0, *)
internal struct RecordTokenRaw: Codable {
    internal let token: RecordTokenRaw.Token
    internal let transaction: RecordTokenRaw.Transaction?
    internal let locale: String?
    internal let storefront: String?

    internal enum CodingKeys: String, CodingKey {
        case token = "token"
        case transaction = "transaction"
        case locale = "locale"
        case storefront = "storefront"
    }
    
    internal static func fromParameters(
        token: ExternalPurchaseToken,
        transactionUID: String? = nil,
        completion: @escaping (RecordTokenRaw) -> Void
    ) {
        Task {
            // Use device locale settings for consistent 2-letter ISO 3166-1 alpha-2 country codes
            let locale = Locale.current.regionCode?.uppercased()

            // Get storefront (installation source) from MarketplaceKit
            var storefront: String?
            
            switch await try? AppDistributor.current {
            case .appStore:
                storefront = "app_store"
            case .marketplace(let marketplace):
                storefront = marketplace
            case .testFlight:
                storefront = "testflight"
            case .web:
                storefront = "web"
            case .other:
                storefront = "other"
            default:
                storefront = nil
            }

            Utils.log("Reporting External Purchase Token - Locale: \(locale ?? "nil"), Storefront: \(storefront ?? "nil")")

            completion(
                RecordTokenRaw(
                    token: RecordTokenRaw.Token.fromParameters(token: token),
                    transaction: transactionUID.flatMap {
                        RecordTokenRaw.Transaction.fromParameters(transactionUID: $0)
                    },
                    locale: locale,
                    storefront: storefront
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
