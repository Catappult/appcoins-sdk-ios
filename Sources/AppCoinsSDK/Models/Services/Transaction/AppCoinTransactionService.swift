//
//  File.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

protocol AppCoinTransactionService {
    func getBalance(wa: String, result: @escaping (Result<AppCoinBalanceRaw, AppcTransactionError>) -> Void)
}
