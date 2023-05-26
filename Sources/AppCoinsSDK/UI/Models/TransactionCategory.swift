//
//  File.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation

enum TransactionCategory: String, Codable {
    
    init(from decoder: Decoder) throws {
        self = try TransactionCategory(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .STANDARD
    }
    
    case TRANSFER_OFF_CHAIN = "Transfer OffChain"
    case TOP_UP = "Topup OffChain"
    case TOP_UP_REVERT = "Topup Revert OffChain"
    case IAP_OFFCHAIN = "IAP OffChain"
    case IAP_REVERT = "IAP Revert OffChain"
    case BONUS = "bonus"
    case BONUS_REVERT = "Bonus Revert OffChain"
    case ADS_OFF_CHAIN = "PoA OffChain"
    case ETHER_TRANSFER = "Ether Transfer"
    case ESKILLS_REWARD = "Eskills Reward OffChain"
    case IAP = "IAP"
    case STANDARD
}
