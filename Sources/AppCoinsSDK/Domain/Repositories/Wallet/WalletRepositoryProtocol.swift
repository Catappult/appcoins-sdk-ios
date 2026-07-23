//
//  WalletRepositoryProtocol.swift
//
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal protocol WalletRepositoryProtocol {

    func getActiveWallet(completion: @escaping (Wallet?) -> Void)
    func setActiveWallet(user: UserWallet)
    func setActiveWallet(guest: GuestWallet)
    func hasStoredActiveWallet() -> Bool
    func getGuestWallet(guestUID: String, completion: @escaping (Result<GuestWallet, APPCServiceError>) -> Void)
    func getWalletList(completion: @escaping ([Wallet]) -> Void)

}
