//
//  WalletRepositoryProtocol.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal protocol WalletRepositoryProtocol {
    
    func getClientWallet() -> ClientWallet?
    func getGuestWallet(guestUID: String, completion: @escaping (Result<GuestWallet, APPCServiceError>) -> Void)
    func getWalletList() -> [ClientWallet]
    func importWallet(keystore: String, password: String, privateKey: String, completion: @escaping (Result<ClientWallet?, WalletLocalErrors>) -> Void)
    func getWalletSyncingStatus() -> WalletSyncingStatus
    func updateWalletSyncingStatus(status: WalletSyncingStatus)
    
}
