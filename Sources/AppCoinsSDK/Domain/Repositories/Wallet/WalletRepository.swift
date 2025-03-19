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
    private var appcService: APPCService = APPCServiceClient()
    
    private let ActiveWalletCache: Cache<String, ClientWallet?> = Cache<String, ClientWallet?>.shared(cacheName: "ActiveWalletCache")
    private let WalletListCache: Cache<String, [ClientWallet]> = Cache<String, [ClientWallet]>.shared(cacheName: "WalletListCache")
    private var appcTransactionService: AppCoinTransactionService = AppCoinTransactionClient()
    
    internal func getClientWallet() -> ClientWallet? {
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
    
    internal func getWalletList() -> [ClientWallet] {
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
    
    internal func getWalletBalance(wallet: Wallet, currency: Currency, completion: @escaping (Result<Balance, AppcTransactionError>) -> Void) {
        appcTransactionService.getBalance(wallet: wallet, currency: currency) {
            result in
            
            switch result {
            case .success(let balanceRaw):
                completion(.success(Balance(raw: balanceRaw, currency: currency)))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    internal func getWalletPrivateKey(wallet: Wallet) -> Data? {
        return walletService.getPrivateKey(wallet: wallet)
    }
}
