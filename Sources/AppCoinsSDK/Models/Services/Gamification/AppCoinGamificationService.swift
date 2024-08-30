//
//  AppCoinGamificationService.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal protocol AppCoinGamificationService {
    
    func getTransactionBonus(wallet: Wallet, package_name: String, amount: String, currency: Currency, result: @escaping (Result<TransactionBonusRaw, TransactionError>) -> Void)
    
}
