//
//  ExternalPurchaseTokenDatabaseClient.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/01/2026.
//

import Foundation
@_implementationOnly import SwiftData

@available(iOS 17, *)
internal class ExternalPurchaseTokenDatabaseClient: ExternalPurchaseTokenDatabaseService {
    
    private let context: ModelContext

    internal init(context: ModelContext) {
        self.context = context
    }
    
    internal func add(
        appAppleId: Int,
        bundleId: String,
        tokenCreationDate: Int64,
        externalPurchaseId: String,
        tokenType: String,
        transactionUID: String? = nil
    ) -> ExternalPurchaseTokenModel? {
        do {
            let item = ExternalPurchaseTokenModel(
                appAppleId: appAppleId,
                bundleId: bundleId,
                tokenCreationDate: tokenCreationDate,
                externalPurchaseId: externalPurchaseId,
                tokenType: tokenType,
                transactionUID: transactionUID
            )
            context.insert(item)
            try context.save()
            return item
        } catch {
            Utils.log("Failed to store token in local database with error \(error) at add:ExternalPurchaseTokenClient.swift")
            return nil
        }
    }

    internal func associateTransaction(_ item: ExternalPurchaseTokenModel, transactionUID: String) {
        do {
            item.transactionUID = transactionUID
            try context.save()
        } catch {
            Utils.log("Failed to associate transaction in local database with error \(error) at associateTransaction:ExternalPurchaseTokenClient.swift")
        }
    }
    
    internal func markTokenReported(_ item: ExternalPurchaseTokenModel) {
        do {
            item.reportedTokenAt = .now
            try context.save()
        } catch {
            Utils.log("Failed to mark token as reported in local database with error \(error) at markTokenReported:ExternalPurchaseTokenClient.swift")
        }
    }
    
    internal func markTransactionReported(_ item: ExternalPurchaseTokenModel) {
        do {
            item.reportedTransactionAt = .now
            try context.save()
        } catch {
            Utils.log("Failed to mark transaction as reported in local database with error \(error) at markTransactionReported:ExternalPurchaseTokenClient.swift")
        }
    }

    internal func latestToken() -> ExternalPurchaseTokenModel? {
        do {
            var descriptor = FetchDescriptor<ExternalPurchaseTokenModel>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            descriptor.fetchLimit = 1
            return try context.fetch(descriptor).first
        } catch {
            Utils.log("Failed to fetch latest token from local database with error \(error) at latestToken:ExternalPurchaseTokenClient.swift")
            return nil
        }
    }
    
    internal func getUnreportedTokens() -> [ExternalPurchaseTokenModel] {
        let descriptor = FetchDescriptor<ExternalPurchaseTokenModel>(
            predicate: #Predicate {
                $0.reportedTokenAt == nil
            }
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            Utils.log("Failed to fetch unreported tokens: \(error) at getUnreported:ExternalPurchaseTokenClient.swift")
            return []
        }
    }
    
    internal func getUnreportedTransactions() -> [ExternalPurchaseTokenModel] {
        let descriptor = FetchDescriptor<ExternalPurchaseTokenModel>(
            predicate: #Predicate {
                $0.reportedTransactionAt == nil && $0.transactionUID != nil
            }
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            Utils.log("Failed to fetch unreported tokens with associated transactions: \(error) at getUnreported:ExternalPurchaseTokenClient.swift")
            return []
        }
    }
    
}
