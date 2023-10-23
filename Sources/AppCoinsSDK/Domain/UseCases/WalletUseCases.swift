//
//  WalletUseCases.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal class WalletUseCases {
    
    static var shared : WalletUseCases = WalletUseCases()
    
    private var repository: WalletRepositoryProtocol
    
    private init(repository: WalletRepositoryProtocol = WalletRepository()) {
        self.repository = repository
    }
    
    internal func getWalletList() -> [Wallet] {
        return repository.getWalletList()
    }
    
    internal func getClientWallet() -> Wallet? {
        return repository.getClientWallet()
    }
    
    internal func importWallet(keystore: String, password: String, privateKey: String, completion: @escaping (Result<Wallet?, WalletLocalErrors>) -> Void) {
        repository.importWallet(keystore: keystore, password: password, privateKey: privateKey) { result in completion(result) }
    }
    
    internal func getWalletSyncingStatus() -> WalletSyncingStatus { return repository.getWalletSyncingStatus() }
    
    internal func updateWalletSyncingStatus(status: WalletSyncingStatus) { repository.updateWalletSyncingStatus(status: status) }
}
