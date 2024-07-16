//
//  WalletUseCases.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal class WalletUseCases {
    
    static var shared : WalletUseCases = WalletUseCases()
    
    private var repository: WalletRepositoryProtocol
    
    private init(repository: WalletRepositoryProtocol = WalletRepository()) {
        self.repository = repository
    }
    
    internal func getWallet(completion: @escaping (Result<Wallet, APPCServiceError>) -> Void)  {
        // Should be fetched from MMP
        var guestUID: String = "0123456789012345678901234567890123456789"
        
        repository.getGuestWallet(guestUID: guestUID) {
            result in
            
            switch result {
            case .success(let guestWallet):
                completion(.success(guestWallet))
            case .failure(let error):
                if let clientWallet = self.repository.getClientWallet() {
                    completion(.success(clientWallet))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    internal func getWalletList(completion: @escaping ([Wallet]) -> Void) {
        // Should be fetched from MMP
        var guestUID: String = "0123456789012345678901234567890123456789"
        
        repository.getGuestWallet(guestUID: guestUID) {
            result in
            
            var clientWallets: [Wallet] = self.repository.getWalletList()
            
            switch result {
            case .success(let guestWallet):
                clientWallets.append(guestWallet)
                completion(clientWallets)
            case .failure(_):
                completion(clientWallets)
            }
            
        }
    }
    
    internal func getClientWallet() -> ClientWallet? {
        return repository.getClientWallet()
    }
    
    internal func importWallet(keystore: String, password: String, privateKey: String, completion: @escaping (Result<ClientWallet?, WalletLocalErrors>) -> Void) {
        repository.importWallet(keystore: keystore, password: password, privateKey: privateKey) { result in completion(result) }
    }
    
    internal func getWalletSyncingStatus() -> WalletSyncingStatus { return repository.getWalletSyncingStatus() }
    
    internal func updateWalletSyncingStatus(status: WalletSyncingStatus) { repository.updateWalletSyncingStatus(status: status) }
}
