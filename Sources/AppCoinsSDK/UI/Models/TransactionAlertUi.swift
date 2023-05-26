//
//  TransactionAlertUi.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation

struct TransactionAlertUi {
    
    let domain: String?
    let description: String?
    let category: TransactionCategory?
    let sku: String?
    let moneyAmount: Double
    let moneyCurrency: String
    let appcAmount: Double
    let bonusCurrency: String
    let bonusAmount: Double
    let walletBalance: String
    let paymentMethods: [PaymentMethodUi]
    
    func getTitle() -> String {
        return description ?? getCategory()
    }
    
    func getCategory() -> String {
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
