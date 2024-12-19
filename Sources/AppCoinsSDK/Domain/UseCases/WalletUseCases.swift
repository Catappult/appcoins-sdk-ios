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
    private var authRepository: AuthRepositoryProtocol
    private var mmpRepository: MMPRepositoryProtocol
    
    private init(repository: WalletRepositoryProtocol = WalletRepository(), authRepository: AuthRepositoryProtocol = AuthRepository(), mmpRepository: MMPRepositoryProtocol = MMPRepository()) {
        self.repository = repository
        self.authRepository = authRepository
        self.mmpRepository = mmpRepository
    }
    
    internal func getWallet(completion: @escaping (Result<Wallet, APPCServiceError>) -> Void)  {
        authRepository.getUserWallet() { userWallet in
            if let userWallet = userWallet {
                print("Using a user wallet: \(userWallet.getWalletAddress())")
                completion(.success(userWallet))
            } else {
                if let clientWallet = self.repository.getClientWallet() { completion(.success(clientWallet)) }
                else { completion(.failure(.failed(message: "Failed to get wallet", description: "There is no active wallet, and it was impossible to create a new wallet at WalletUseCases.swift:getWallet", request: nil))) }
            }
        }
        
        // We will not be using guestWallets yet
//        if let guestUID = mmpRepository.getGuestUID() {
//            repository.getGuestWallet(guestUID: guestUID) {
//                result in
//                
//                switch result {
//                case .success(let guestWallet):
//                    completion(.success(guestWallet))
//                case .failure(let error):
//                    if let clientWallet = self.repository.getClientWallet() {
//                        completion(.success(clientWallet))
//                    } else {
//                        completion(.failure(error))
//                    }
//                }
//            }
//        }
    }
    
    internal func getWalletList(completion: @escaping ([Wallet]) -> Void) {
        authRepository.getUserWallet() { userWallet in            
            var clientWallets: [Wallet] = self.repository.getWalletList()
            
            if let userWallet = userWallet { clientWallets.append(userWallet) }
            completion(clientWallets)
        }
        
        // We will not be using guestWallets yet
//        if let guestUID = mmpRepository.getGuestUID() {
//            repository.getGuestWallet(guestUID: guestUID) {
//                result in
//                
//                var clientWallets: [Wallet] = self.repository.getWalletList()
//                
//                switch result {
//                case .success(let guestWallet):
//                    clientWallets.append(guestWallet)
//                    completion(clientWallets)
//                case .failure(_):
//                    completion(clientWallets)
//                }
//                
//            }
//        }
    }
    
    internal func getClientWallet() -> ClientWallet? {
        return repository.getClientWallet()
    }
    
    internal func importWallet(keystore: String, password: String, privateKey: String, completion: @escaping (Result<ClientWallet?, WalletLocalErrors>) -> Void) {
        repository.importWallet(keystore: keystore, password: password, privateKey: privateKey) { result in completion(result) }
    }
    
    internal func getWalletSyncingStatus() -> WalletSyncingStatus { return repository.getWalletSyncingStatus() }
    
    internal func updateWalletSyncingStatus(status: WalletSyncingStatus) { repository.updateWalletSyncingStatus(status: status) }
    
    internal func getWalletBalance(wallet: Wallet, currency: Currency, completion: @escaping (Result<Balance, AppcTransactionError>) -> Void) {
        repository.getWalletBalance(wallet: wallet, currency: currency) { result in completion(result) }
    }
    
    internal func getWalletPrivateKey(wallet: Wallet) -> Data? {
        return repository.getWalletPrivateKey(wallet: wallet)
    }
}
