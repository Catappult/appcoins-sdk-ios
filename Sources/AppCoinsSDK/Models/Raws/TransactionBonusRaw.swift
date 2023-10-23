//
//  TransactionBonusRaw.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal struct TransactionBonusRaw: Codable {

    internal let level: Int
    internal let bonus: Double
    internal let status: String
    internal let currency: String
    internal let perks_bonus: [PerkBonusRaw]?
    
    internal enum CodingKeys: String, CodingKey {
        case level = "level"
        case bonus = "bonus"
        case status = "status"
        case currency = "currency"
        case perks_bonus = "perks_bonus"
    }
    
}

internal struct PerkBonusRaw: Codable {
    
    internal let perk: String
    internal let bonus_amount: Double
    
    internal enum CodingKeys: String, CodingKey {
        case perk = "perk"
        case bonus_amount = "bonus_amount"
    }
    
}
