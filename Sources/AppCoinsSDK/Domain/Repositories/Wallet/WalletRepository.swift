//
//  File.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

class WalletRepository: WalletRepositoryProtocol {
        
    private var walletService: WalletLocalService = WalletLocalClient()
    
    func getClientWallet() -> Wallet? {
        
        do {
            if let wallet = walletService.getActiveWallet() { return wallet }
            else { if let newWallet = try walletService.createNewWallet() { return newWallet } }
        } catch {
            return nil
        }
        return nil
        
    }
}
