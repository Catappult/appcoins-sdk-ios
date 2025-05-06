//
//  WalletManagerClient.swift
//
//
//  Created by aptoide on 11/04/2025.
//

import Foundation

internal class WalletManagerClient: WalletManagerService {
    
    internal func getActiveWallet() -> StorageWalletRaw? {
        return Utils.readFromKeychain(key: "active-wallet", type: StorageWalletRaw.self)
    }
    
    internal func setActiveWallet(wallet: StorageWalletRaw) {
        try? Utils.writeToKeychain(key: "active-wallet", value: wallet)
    }
    
    internal func getWalletList() -> [StorageWalletRaw] {
        guard let wallets = Utils.readFromKeychain(key: "wallet-list", type: [StorageWalletRaw].self) else {
            return []
        }
        
        return wallets
    }
    
    internal func setWalletList(walletList: [StorageWalletRaw]) {
        try? Utils.writeToKeychain(key: "wallet-list", value: walletList)
    }
}
