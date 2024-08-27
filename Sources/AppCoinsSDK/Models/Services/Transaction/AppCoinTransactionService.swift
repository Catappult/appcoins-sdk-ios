//
//  AppCoinTransactionService.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal protocol AppCoinTransactionService {
    func getBalance(wa: String, currency: Currency?, currencyString: String?, result: @escaping (Result<AppCoinBalanceRaw, AppcTransactionError>) -> Void)
}
