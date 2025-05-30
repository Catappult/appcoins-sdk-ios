//
//  WalletRepository.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation
import SwiftUI

internal class WalletRepository: WalletRepositoryProtocol {
    
    private let walletManagerService: WalletManagerService = WalletManagerClient()
    private let APPCService: APPCService = APPCServiceClient()
    
    private let GuestWalletCache: Cache<String, GuestWallet> = Cache<String, GuestWallet>.shared(cacheName: "GuestWalletCache")
    private let UserWalletCache: Cache<String, UserWallet> = Cache<String, UserWallet>.shared(cacheName: "UserWalletCache")
    
    internal func getActiveWallet(completion: @escaping (Wallet?) -> Void) {
        guard let activeWallet = walletManagerService.getActiveWallet() else {
            completion(nil)
            return
        }
        
        switch activeWallet.type {
        case .guest:
            guard let storageGuestWallet = activeWallet as? StorageWalletRaw.StorageGuestWallet else {
                completion(nil)
                return
            }
            
            getGuestWallet(guestUID: storageGuestWallet.guestUID) { result in
                switch result {
                case .success(let guestWallet):
                    completion(guestWallet)
                case .failure(let failure):
                    completion(nil)
                }
            }
            
        case .user:
            guard let storageUserWallet = activeWallet as? StorageWalletRaw.StorageUserWallet else {
                completion(nil)
                return
            }
            
            getUserWallet(refreshToken: storageUserWallet.refreshToken) { result in
                switch result {
                case .success(let userWallet):
                    completion(userWallet)
                case .failure(let failure):
                    completion(nil)
                }
            }
        }
    }
    
    internal func setActiveWallet(user: UserWallet) {
        let storageWallet = StorageWalletRaw.fromUser(wallet: user)
        walletManagerService.setActiveWallet(wallet: storageWallet)
        
        var storedWallets = walletManagerService.getWalletList()
        if !storedWallets.contains(storageWallet) {
            storedWallets.append(storageWallet)
        }
        
        walletManagerService.setWalletList(walletList: storedWallets)
    }
    
    internal func setActiveWallet(guest: GuestWallet) {
        let storageWallet = StorageWalletRaw.fromGuest(wallet: guest)
        walletManagerService.setActiveWallet(wallet: storageWallet)
        
        var storedWallets = walletManagerService.getWalletList()
        if !storedWallets.contains(storageWallet) {
            storedWallets.append(storageWallet)
        }
        
        walletManagerService.setWalletList(walletList: storedWallets)
    }
    
    internal func getGuestWallet(guestUID: String, completion: @escaping (Result<GuestWallet, APPCServiceError>) -> Void) {
        if let cachedGuestWallet = GuestWalletCache.getValue(forKey: "guest-wallet") {
            completion(.success(cachedGuestWallet))
            return
        }
        
        APPCService.getGuestWallet(guestUID: guestUID) { result in
            switch result {
            case .success(let raw):
                let guestWallet = GuestWallet(guestUID: guestUID, raw: raw)
                self.GuestWalletCache.setValue(guestWallet, forKey: "guest-wallet", storageOption: .memory)
                completion(.success(guestWallet))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    internal func getUserWallet(refreshToken: String, completion: @escaping (Result<UserWallet, APPCServiceError>) -> Void) {
        if let cachedUserWallet = UserWalletCache.getValue(forKey: "user-wallet"),
           !cachedUserWallet.isExpired() {
            completion(.success(cachedUserWallet))
            return
        }
        
        APPCService.refreshUserWallet(refreshToken: refreshToken) { result in
            switch result {
            case .success(let raw):
                let userWallet = UserWallet(raw: raw)
                self.UserWalletCache.setValue(userWallet, forKey: "user-wallet", storageOption: .memory)
                completion(.success(userWallet))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    internal func getWalletList(completion: @escaping ([Wallet]) -> Void) {
        let rawWalletList = walletManagerService.getWalletList()
        
        var wallets: [Wallet] = []
        
        let group = DispatchGroup()
        for wallet in rawWalletList {
            group.enter()
            switch wallet.type {
            case .guest:
                guard case .guest(let storageGuestWallet) = wallet.wallet else {
                    group.leave()
                    continue
                }
                
                getGuestWallet(guestUID: storageGuestWallet.guestUID) { result in
                    switch result {
                    case .success(let guestWallet):
                        wallets.append(guestWallet)
                    case .failure:
                        break
                    }
                    group.leave()
                }
                
            case .user:
                guard case .user(let storageUserWallet) = wallet.wallet else {
                    group.leave()
                    continue
                }
                
                getUserWallet(refreshToken: storageUserWallet.refreshToken) { result in
                    switch result {
                    case .success(let userWallet):
                        wallets.append(userWallet)
                    case .failure:
                        break
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(wallets)
        }
    }
}
