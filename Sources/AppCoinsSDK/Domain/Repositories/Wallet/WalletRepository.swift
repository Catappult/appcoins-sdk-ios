//
//  WalletRepository.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation
import SwiftUI

internal class WalletRepository: WalletRepositoryProtocol {
        
    private var walletService: WalletLocalService = WalletLocalClient()
    
    private let ActiveWalletCache: Cache<String, Wallet?> = Cache(cacheName: "ActiveWalletCache")
    private let WalletListCache: Cache<String, [Wallet]> = Cache(cacheName: "WalletListCache")
    
    internal func getClientWallet() -> Wallet? {
        if let clientWallet = self.ActiveWalletCache.getValue(forKey: "activeWallet") {
            return clientWallet
        } else {
            do {
                if let wallet = walletService.getActiveWallet() {
                    ActiveWalletCache.setValue(wallet, forKey: "activeWallet", storageOption: .memory)
                    return wallet
                }
                else { if let newWallet = try walletService.createNewWallet() {
                    ActiveWalletCache.setValue(newWallet, forKey: "activeWallet", storageOption: .memory)
                    return newWallet
                } }
            } catch {
                return nil
            }
            return nil
        }
    }
    
    internal func getWalletList() -> [Wallet] {
        if let walletList = WalletListCache.getValue(forKey: "walletList") {
            if walletList.isEmpty {
                let newWalletList = walletService.getWalletList()
                WalletListCache.setValue(newWalletList, forKey: "walletList", storageOption: .memory)
                return newWalletList
            } else {
                return walletList
            }
        } else {
            let newWalletList = walletService.getWalletList()
            WalletListCache.setValue(newWalletList, forKey: "walletList", storageOption: .memory)
            return newWalletList
        }
    }
    
    internal func importWallet(keystore: String, password: String, privateKey: String, completion: @escaping (Result<Wallet?, WalletLocalErrors>) -> Void) {
        walletService.importWallet(keystore: keystore, password: password, privateKey: privateKey) { result in
            switch result {
            case .success(let newWallet):
                self.ActiveWalletCache.setValue(newWallet, forKey: "activeWallet", storageOption: .memory)
                self.WalletListCache.removeValue(forKey: "walletList") // next time we need the wallet list we'll get it from the wallet service
                completion(.success(newWallet))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    internal func getWalletSyncingStatus() -> WalletSyncingStatus { return walletService.getWalletSyncingStatus() }
    
    internal func updateWalletSyncingStatus(status: WalletSyncingStatus) { walletService.updateWalletSyncingStatus(status: status) }
}
