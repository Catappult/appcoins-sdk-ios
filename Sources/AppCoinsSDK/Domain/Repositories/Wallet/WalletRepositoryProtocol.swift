//
//  WalletRepositoryProtocol.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal protocol WalletRepositoryProtocol {
    
    func getClientWallet() -> Wallet?
    func getWalletList() -> [Wallet]
    func importWallet(keystore: String, password: String, privateKey: String, completion: @escaping (Result<Wallet?, WalletLocalErrors>) -> Void)
    func getWalletSyncingStatus() -> WalletSyncingStatus
    func updateWalletSyncingStatus(status: WalletSyncingStatus)
    
}
