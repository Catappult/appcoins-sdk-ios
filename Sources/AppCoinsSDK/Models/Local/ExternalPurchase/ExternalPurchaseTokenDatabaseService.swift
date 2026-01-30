//
//  ExternalPurchaseTokenDatabaseService.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/01/2026.
//

import Foundation

@available(iOS 17, *)
internal protocol ExternalPurchaseTokenDatabaseService {
    
    func add(
        appAppleId: Int,
        bundleId: String,
        tokenCreationDate: Int64,
        externalPurchaseId: String,
        tokenType: String,
        transactionUID: String?
    ) -> ExternalPurchaseTokenModel?
    
    func associateTransaction(_ item: ExternalPurchaseTokenModel, transactionUID: String)
    
    func markTokenReported(_ item: ExternalPurchaseTokenModel)
    
    func markTransactionReported(_ item: ExternalPurchaseTokenModel)
    
    func latestToken() -> ExternalPurchaseTokenModel?
    
    func getUnreportedTokens() -> [ExternalPurchaseTokenModel]
    
    func getUnreportedTransactions() -> [ExternalPurchaseTokenModel]
    
}
