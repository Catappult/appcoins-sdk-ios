//
//  Wallet.swift
//  
//
//  Created by aptoide on 12/07/2024.
//

import Foundation

internal protocol Wallet: Codable {
    
    func getBalance(completion: @escaping (Result<Balance, AppcTransactionError>) -> Void)
    func getWalletAddress() -> String
    func getAuthToken() -> String?
    
}
