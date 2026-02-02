//
//  ExternalPurchaseServiceRepositoryProtocol.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/01/2026.
//

import Foundation

internal protocol ExternalPurchaseServiceRepositoryProtocol {
    func reportToken()
    func associateTransaction(transactionUID: String)
    func flushReports()
}
