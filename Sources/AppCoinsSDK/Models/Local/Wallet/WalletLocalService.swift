//
//  WalletLocalService.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal protocol WalletLocalService {
    
    func getActiveWallet() -> ClientWallet?
    func getWalletList() -> [ClientWallet]
    func createNewWallet() throws -> ClientWallet?
    func getPrivateKey(wallet: Wallet) -> Data?
    
}
