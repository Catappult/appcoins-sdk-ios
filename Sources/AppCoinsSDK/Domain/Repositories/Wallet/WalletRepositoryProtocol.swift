//
//  WalletRepositoryProtocol.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal protocol WalletRepositoryProtocol {
    func getClientWallet() -> ClientWallet?
    func getWalletList() -> [ClientWallet]
    func getWalletPrivateKey(wallet: Wallet) -> Data?
}
