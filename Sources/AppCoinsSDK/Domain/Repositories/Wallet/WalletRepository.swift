//
//  WalletRepository.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal class WalletRepository: WalletRepositoryProtocol {
        
    private var walletService: WalletLocalService = WalletLocalClient()
    
    internal var clientWallet : Wallet?
    internal var walletList : [Wallet] = []
    
    internal func getClientWallet() -> Wallet? {
        if let clientWallet = clientWallet {
            return clientWallet
        } else {
            do {
                if let wallet = walletService.getActiveWallet() {
                    self.clientWallet = wallet
                    return wallet
                }
                else { if let newWallet = try walletService.createNewWallet() {
                    self.clientWallet = newWallet
                    return newWallet
                } }
            } catch {
                return nil
            }
            return nil
        }
    }
    
    internal func getWalletList() -> [Wallet] {
        if walletList.isEmpty {
            self.walletList = walletService.getWalletList()
            return walletList
        } else {
            return self.walletList
        }
    }
    
    internal func importWallet(keystore: String, password: String, privateKey: String, completion: @escaping (Result<Wallet?, WalletLocalErrors>) -> Void) {
        walletService.importWallet(keystore: keystore, password: password, privateKey: privateKey) { result in
            switch result {
            case .success(let newWallet):
                self.clientWallet = newWallet
                self.walletList = [] // next time we need the wallet list we'll get it from the wallet service
                completion(.success(newWallet))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    internal func getWalletSyncingStatus() -> WalletSyncingStatus { return walletService.getWalletSyncingStatus() }
    
    internal func updateWalletSyncingStatus(status: WalletSyncingStatus) { walletService.updateWalletSyncingStatus(status: status) }
}
