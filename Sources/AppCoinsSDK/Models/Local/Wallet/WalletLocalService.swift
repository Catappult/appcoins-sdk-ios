//
//  File.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

protocol WalletLocalService {
    
    func getActiveWallet() -> Wallet?
    func createNewWallet() throws -> Wallet?
    
}
