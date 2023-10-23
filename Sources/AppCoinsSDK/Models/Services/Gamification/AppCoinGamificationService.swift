//
//  AppCoinGamificationService.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal protocol AppCoinGamificationService {
    
    func getTransactionBonus(address: String, package_name: String, amount: String, currency: Coin, result: @escaping (Result<TransactionBonusRaw, TransactionError>) -> Void)
    
}
