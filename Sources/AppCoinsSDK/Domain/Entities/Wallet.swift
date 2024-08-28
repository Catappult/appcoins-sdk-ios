//
//  File.swift
//  
//
//  Created by aptoide on 12/07/2024.
//

import Foundation

internal protocol Wallet: Codable {
    
    func getBalance(currency: Currency, completion: @escaping (Result<Balance, AppcTransactionError>) -> Void)
    func getWalletAddress() -> String
    func getSignedWalletAddress() -> String
    func getEWT() -> String?
    
}
