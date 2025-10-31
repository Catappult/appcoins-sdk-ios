//
//  WalletManagerService.swift
//  
//
//  Created by aptoide on 11/04/2025.
//

import Foundation

internal protocol WalletManagerService {
    
    func getActiveWallet() -> StorageWalletRaw?
    func setActiveWallet(wallet: StorageWalletRaw)
    func getWalletList() -> [StorageWalletRaw]
    func setWalletList(walletList: [StorageWalletRaw])
    
}
