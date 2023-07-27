//
//  File.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

class WalletUseCases {
    
    static var shared : WalletUseCases = WalletUseCases()
    
    private var repository: WalletRepositoryProtocol
    
    private init(repository: WalletRepositoryProtocol = WalletRepository()) {
        self.repository = repository
    }
    
    func getClientWallet() -> Wallet? {
        return repository.getClientWallet()
    }
    
    
}
