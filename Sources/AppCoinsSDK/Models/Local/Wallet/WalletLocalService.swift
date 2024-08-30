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
    func importWallet(keystore: String, password: String, privateKey: String, completion: @escaping (Result<ClientWallet?, WalletLocalErrors>) -> Void)
    func getPrivateKey(wallet: Wallet) -> Data?
    func getWalletSyncingStatus() -> WalletSyncingStatus
    func updateWalletSyncingStatus(status: WalletSyncingStatus)
    
}
