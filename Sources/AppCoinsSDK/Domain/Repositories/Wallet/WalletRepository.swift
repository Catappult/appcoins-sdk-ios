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
    private var appcTransactionService: AppCoinTransactionService = AppCoinTransactionClient()
    
    private let ActiveWalletCache: Cache<String, ClientWallet?> = Cache(cacheName: "ActiveWalletCache")
    private let WalletListCache: Cache<String, [ClientWallet]> = Cache(cacheName: "WalletListCache")
    
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
    
    internal func getGuestWallet(guestUID: String, completion: @escaping (Result<GuestWallet, APPCServiceError>) -> Void) {
        appcService.getGuestWallet(guestUID: guestUID) { result in
            switch result {
            case .success(let guestWalletRaw):
                if let ewt = guestWalletRaw.ewt, let signature = guestWalletRaw.signature {
                    completion(.success(GuestWallet(address: guestWalletRaw.address, ewt: ewt, signature: signature)))
                } else {
                    completion(.failure(.failed(message: "Get Guest Wallet Failed", description: "Guest ewt or signature is miss", request: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
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
    
    internal func importWallet(keystore: String, password: String, privateKey: String, completion: @escaping (Result<ClientWallet?, WalletLocalErrors>) -> Void) {
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
