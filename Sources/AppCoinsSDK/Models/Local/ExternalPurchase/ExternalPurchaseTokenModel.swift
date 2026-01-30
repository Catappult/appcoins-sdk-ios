//
//  ExternalPurchaseTokenTable.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/01/2026.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
final class ExternalPurchaseTokenModel {
    @Attribute(.unique) var id: UUID

    var appAppleId: Int
    var bundleId: String
    var tokenCreationDate: Int64
    var externalPurchaseId: String
    var tokenType: String
    var transactionUID: String?
    var createdAt: Date
    var reportedTokenAt: Date?
    var reportedTransactionAt: Date?

    init(
        appAppleId: Int,
        bundleId: String,
        tokenCreationDate: Int64,
        externalPurchaseId: String,
        tokenType: String,
        transactionUID: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = UUID()
        self.appAppleId = appAppleId
        self.bundleId = bundleId
        self.tokenCreationDate = tokenCreationDate
        self.externalPurchaseId = externalPurchaseId
        self.tokenType = tokenType
        self.transactionUID = transactionUID
        self.createdAt = createdAt
        self.reportedTokenAt = nil
        self.reportedTransactionAt = nil
    }

    var hasReportedToken: Bool { reportedTokenAt != nil }
    
    var hasReportedTransaction: Bool { reportedTransactionAt != nil }
}
