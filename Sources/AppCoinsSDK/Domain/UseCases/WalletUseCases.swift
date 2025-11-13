//
//  WalletUseCases.swift
//
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal class WalletUseCases {
    
    static var shared: WalletUseCases = WalletUseCases()
    
    private var repository: WalletRepositoryProtocol
    private var mmpRepository: MMPRepositoryProtocol
    
    private init(repository: WalletRepositoryProtocol = WalletRepository(), mmpRepository: MMPRepositoryProtocol = MMPRepository()) {
        self.repository = repository
        self.mmpRepository = mmpRepository
    }
    
    internal func getWallet(completion: @escaping (Result<Wallet, APPCServiceError>) -> Void) {
        repository.getActiveWallet() { activeWallet in
            if let activeWallet = activeWallet {
                
                if let activeWallet = activeWallet as? UserWallet {
                    Utils.log("Active Wallet (Type: User, Address: \(activeWallet.address))")
                } else if let activeWallet = activeWallet as? GuestWallet {
                    Utils.log("Active Wallet (Type: Guest, Address: \(activeWallet.address))")
                }
                
                completion(.success(activeWallet))
                return
            }
            
            self.getGuestWallet() { result in
                switch result {
                case .success(let guestWallet):
                    self.repository.setActiveWallet(guest: guestWallet)
                    completion(.success(guestWallet))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    internal func setActiveWallet(user: UserWallet) {
        repository.setActiveWallet(user: user)
        Utils.log("Set Active Wallet (Type: User, Address: \(user.address))")
    }
    
    internal func setActiveWallet(guest: GuestWallet) {
        repository.setActiveWallet(guest: guest)
        Utils.log("Set Active Wallet (Type: Guest, Address: \(guest.address))")
    }
    
    internal func getGuestWallet(completion: @escaping (Result<GuestWallet, APPCServiceError>) -> Void) {
        guard let guestUID = mmpRepository.getGuestUID() else {
            Utils.log("GuestUID not found at WalletUseCases.swift:getGuestWallet", level: .error)
            
            completion(.failure(.failed(
                message: "Guest ID Not Found",
                description: "Guest ID not found at WalletUseCases.swift:getGuestWallet"
            )))
            return
        }
        
        repository.getGuestWallet(guestUID: guestUID) {
            result in

            switch result {
            case .success(let guestWallet):
                Utils.log("Returning guest wallet with address: \(guestWallet.address) at WalletUseCases.swift:getGuestWallet")
                completion(.success(guestWallet))
            case .failure(let error):
                Utils.log(
                    "Get guest wallet failed with error: \(error) at WalletUseCases.swift:getGuestWallet",
                    level: .error
                )
                completion(.failure(error))
            }
        }
    }
    
    internal func getWalletList(completion: @escaping ([Wallet]) -> Void) {
        repository.getWalletList { result in 
            Utils.log("Wallet List")
            
            for wallet in result {
                if let wallet = wallet as? UserWallet {
                    Utils.log("– Wallet (Type: User, Address: \(wallet.address))")
                } else if let wallet = wallet as? GuestWallet {
                    Utils.log("– Wallet (Type: Guest, Address: \(wallet.address))")
                }
            }
            
            completion(result)
        }
    }
}
