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
        
        switch activeWallet.wallet {
        case .guest(let storageGuestWallet):
            getGuestWallet(guestUID: storageGuestWallet.guestUID) { result in
                switch result {
                case .success(let guestWallet):
                    completion(guestWallet)
                case .failure(let failure):
                    completion(nil)
                }
            }
            
        case .user(let storageUserWallet):
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
        let newUserWallet = StorageWalletRaw.fromUser(wallet: user)
        walletManagerService.setActiveWallet(wallet: newUserWallet)
        
        var newWalletList: [StorageWalletRaw] = []
        var storedWallets = walletManagerService.getWalletList()
        for storedWallet in storedWallets {
            switch storedWallet.wallet {
            case .guest(let storageGuestWallet):
                newWalletList.append(storedWallet)
            case .user(let storageUserWallet):
                if storageUserWallet.address != user.address {
                    newWalletList.append(storedWallet)
                }
            }
        }
        newWalletList.append(newUserWallet)
        
        walletManagerService.setWalletList(walletList: newWalletList)
    }
    
    internal func setActiveWallet(guest: GuestWallet) {
        let newGuestWallet = StorageWalletRaw.fromGuest(wallet: guest)
        walletManagerService.setActiveWallet(wallet: newGuestWallet)
        
        var newWalletList: [StorageWalletRaw] = []
        var storedWallets = walletManagerService.getWalletList()
        for storedWallet in storedWallets {
            switch storedWallet.wallet {
            case .guest(let storageGuestWallet):
                if storageGuestWallet.guestUID != guest.guestUID {
                    newWalletList.append(storedWallet)
                }
            case .user(let storageUserWallet):
                newWalletList.append(storedWallet)
            }
        }
        newWalletList.append(newGuestWallet)
        
        walletManagerService.setWalletList(walletList: newWalletList)
    }
    
    internal func getGuestWallet(guestUID: String, completion: @escaping (Result<GuestWallet, APPCServiceError>) -> Void) {
        if let cachedGuestWallet = GuestWalletCache.getValue(forKey: guestUID) {
            completion(.success(cachedGuestWallet))
            return
        }
        
        APPCService.getGuestWallet(guestUID: guestUID) { result in
            switch result {
            case .success(let raw):
                let guestWallet = GuestWallet(guestUID: guestUID, raw: raw)
                self.GuestWalletCache.setValue(guestWallet, forKey: guestUID, storageOption: .memory)
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
        
        var wallets: [Wallet?] = Array(repeating: nil, count: rawWalletList.count)
        
        let group = DispatchGroup()
        for (index, wallet) in rawWalletList.enumerated() {
            group.enter()
            
            switch wallet.type {
            case .guest:
                guard case .guest(let storageGuestWallet) = wallet.wallet else {
                    group.leave()
                    continue
                }
                
                getGuestWallet(guestUID: storageGuestWallet.guestUID) { result in
                    if case .success(let guestWallet) = result {
                        wallets[index] = guestWallet
                    }
                    group.leave()
                }
                
            case .user:
                guard case .user(let storageUserWallet) = wallet.wallet else {
                    group.leave()
                    continue
                }
                
                getUserWallet(refreshToken: storageUserWallet.refreshToken) { result in
                    if case .success(let userWallet) = result {
                        wallets[index] = userWallet
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(wallets.compactMap { $0 }) // Filter out nils but preserve order of successes
        }
    }
}
