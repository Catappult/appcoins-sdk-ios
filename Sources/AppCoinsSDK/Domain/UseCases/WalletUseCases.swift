//
//  File.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

class WalletUseCases {
    
    private var repository: WalletRepositoryProtocol
    
    init(repository: WalletRepositoryProtocol = WalletRepository()) {
        self.repository = repository
    }
    
    func getClientWallet() -> Wallet? {
        return repository.getClientWallet()
    }
    
    
}
