//
//  File.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

struct TransactionBonusRaw: Codable {

    let level: Int
    let bonus: Double
    let status: String
    let currency: String
    let perks_bonus: [PerkBonusRaw]?
    
    enum CodingKeys: String, CodingKey {
        case level = "level"
        case bonus = "bonus"
        case status = "status"
        case currency = "currency"
        case perks_bonus = "perks_bonus"
    }
    
}

struct PerkBonusRaw: Codable {
    
    let perk: String
    let bonus_amount: Double
    
    enum CodingKeys: String, CodingKey {
        case perk = "perk"
        case bonus_amount = "bonus_amount"
    }
    
}
