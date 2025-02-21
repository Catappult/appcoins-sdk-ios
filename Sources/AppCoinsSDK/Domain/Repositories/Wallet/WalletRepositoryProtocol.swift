//
//  WalletRepositoryProtocol.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal protocol WalletRepositoryProtocol {
    
    func getClientWallet() -> ClientWallet?
    func getGuestWallet(guestUID: String, completion: @escaping (Result<GuestWallet, APPCServiceError>) -> Void)
    func getWalletList() -> [ClientWallet]
    func getWalletBalance(wallet: Wallet, currency: Currency, completion: @escaping (Result<Balance, AppcTransactionError>) -> Void)
    func getWalletPrivateKey(wallet: Wallet) -> Data?
    
}
