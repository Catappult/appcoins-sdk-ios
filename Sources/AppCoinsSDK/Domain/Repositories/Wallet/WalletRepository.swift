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
    private let UserWalletCache: Cache<String, UserWallet>   = Cache<String, UserWallet>.shared(cacheName: "UserWalletCache")

    internal func hasStoredActiveWallet() -> Bool {
        return walletManagerService.getActiveWallet() != nil
    }

    internal func getActiveWallet(completion: @escaping (Wallet?) -> Void) {
        guard let activeWallet = walletManagerService.getActiveWallet() else {
            completion(nil)
            return
        }

        switch activeWallet.wallet {
        case .guest(let storageGuestWallet):
            getGuestWallet(guestUID: storageGuestWallet.guestUID) { result in
                switch result {
                case .success(let guestWallet): completion(guestWallet)
                case .failure: completion(nil)
                }
            }

        case .user(let storageUserWallet):
            getUserWallet(address: storageUserWallet.address, refreshToken: storageUserWallet.refreshToken) { result in
                switch result {
                case .success(let userWallet): completion(userWallet)
                case .failure: completion(nil)
                }
            }
        }
    }

    internal func setActiveWallet(user: UserWallet) {
        let newUserWallet = StorageWalletRaw.fromUser(wallet: user)
        walletManagerService.setActiveWallet(wallet: newUserWallet)
        // Fix: populate cache immediately so getActiveWallet/getWalletList don't need a
        // network round-trip right after the wallet is set.
        UserWalletCache.setValue(user, forKey: user.address, storageOption: .memory)

        var newWalletList: [StorageWalletRaw] = []
        let storedWallets = walletManagerService.getWalletList()
        for storedWallet in storedWallets {
            switch storedWallet.wallet {
            case .guest:
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
        let storedWallets = walletManagerService.getWalletList()
        for storedWallet in storedWallets {
            switch storedWallet.wallet {
            case .guest(let storageGuestWallet):
                if storageGuestWallet.guestUID != guest.guestUID {
                    newWalletList.append(storedWallet)
                }
            case .user:
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

    // Fix: keyed by address (not the hardcoded "user-wallet") so multiple user wallets
    // each get their own cache slot and don't collide in getWalletList.
    private func getUserWallet(address: String, refreshToken: String, completion: @escaping (Result<UserWallet, APPCServiceError>) -> Void) {
        let cachedWallet = UserWalletCache.getValue(forKey: address)
        if let cachedWallet = cachedWallet, !cachedWallet.isExpired() {
            completion(.success(cachedWallet))
            return
        }

        APPCService.refreshUserWallet(refreshToken: refreshToken) { result in
            switch result {
            case .success(let raw):
                let userWallet = UserWallet(raw: raw)
                Utils.log("refreshUserWallet succeeded for address: \(userWallet.address)")
                self.UserWalletCache.setValue(userWallet, forKey: address, storageOption: .memory)
                self.persistRefreshedWallet(userWallet)
                completion(.success(userWallet))
            case .failure(let error):
                Utils.log("refreshUserWallet failed with error: \(error)", level: .error)
                if let staleWallet = cachedWallet {
                    Utils.log("refreshUserWallet falling back to stale cached wallet for address: \(address)")
                    completion(.success(staleWallet))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    private func persistRefreshedWallet(_ userWallet: UserWallet) {
        let updatedRaw = StorageWalletRaw.fromUser(wallet: userWallet)

        var walletList = walletManagerService.getWalletList()
        for (i, stored) in walletList.enumerated() {
            if case .user(let w) = stored.wallet, w.address == userWallet.address {
                walletList[i] = updatedRaw
                walletManagerService.setWalletList(walletList: walletList)
                break
            }
        }

        if let active = walletManagerService.getActiveWallet(),
           case .user(let activeUser) = active.wallet,
           activeUser.address == userWallet.address {
            walletManagerService.setActiveWallet(wallet: updatedRaw)
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
                    if case .success(let guestWallet) = result { wallets[index] = guestWallet }
                    group.leave()
                }

            case .user:
                guard case .user(let storageUserWallet) = wallet.wallet else {
                    group.leave()
                    continue
                }
                getUserWallet(address: storageUserWallet.address, refreshToken: storageUserWallet.refreshToken) { result in
                    if case .success(let userWallet) = result { wallets[index] = userWallet }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            let resolvedWallets = wallets.compactMap { $0 }

            // Deduplicate by address, preferring UserWallet over GuestWallet.
            var seen: [String: (index: Int, isUser: Bool)] = [:]
            var deduplicated: [Wallet] = []

            for wallet in resolvedWallets {
                let address = wallet.getWalletAddress()
                let isUser = wallet is UserWallet

                if let existing = seen[address] {
                    if isUser && !existing.isUser {
                        deduplicated[existing.index] = wallet
                        seen[address] = (index: existing.index, isUser: true)
                    }
                } else {
                    seen[address] = (index: deduplicated.count, isUser: isUser)
                    deduplicated.append(wallet)
                }
            }

            completion(deduplicated)
        }
    }
}
