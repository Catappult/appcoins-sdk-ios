//
//  TransactionAlertUi.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation

internal struct TransactionAlertUi {
    
    internal let domain: String?
    internal let description: String?
    internal let category: TransactionCategory?
    internal let sku: String?
    internal let moneyAmount: Double
    internal let moneyCurrency: Currency
    internal let appcAmount: Double
    internal let bonusAmount: Double
    internal let bonusCurrency: Currency
    internal let balanceAmount: Double
    internal let balanceCurrency: Currency
    internal var paymentMethods: [PaymentMethod]
    
    internal func getTitle() -> String {
        return description ?? getCategory()
    }
    
    internal func getCategory() -> String {
        switch category {
        case .TRANSFER_OFF_CHAIN: return "Transfer"
        case .BONUS: return "Bonus"
        case .BONUS_REVERT: return "Reverted Bonus"
        case .TOP_UP: return "Top Up"
        case .TOP_UP_REVERT: return "Top-up Refund"
        case .IAP_OFFCHAIN: return "Transfer"
        case .IAP: return "IAP"
        case .IAP_REVERT: return "Purchase Refund"
        case .ESKILLS_REWARD: return "Eskills Reward"
        case .STANDARD: return "STANDARD"
        case .ADS_OFF_CHAIN: return "ADS_OFF_CHAIN"
        case .ETHER_TRANSFER: return "ETHER_TRANSFER"
        case .none: return "STANDARD"
        }
    }
    
}
