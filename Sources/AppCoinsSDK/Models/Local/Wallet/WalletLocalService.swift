//
//  WalletLocalService.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal protocol WalletLocalService {
    
    func getActiveWallet() -> Wallet?
    func getWalletList() -> [Wallet]
    func createNewWallet() throws -> Wallet?
    func importWallet(keystore: String, password: String, privateKey: String, completion: @escaping (Result<Wallet?, WalletLocalErrors>) -> Void)
    func getPrivateKey(address: String) -> Data?
    func getWalletSyncingStatus() -> WalletSyncingStatus
    func updateWalletSyncingStatus(status: WalletSyncingStatus)
    
}
