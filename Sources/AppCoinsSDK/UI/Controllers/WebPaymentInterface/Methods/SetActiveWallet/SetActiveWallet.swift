//
//  SetActiveWallet.swift
//
//
//  Created by aptoide on 11/04/2025.
//

import Foundation

internal class SetActiveWallet {
    
    internal static let shared = SetActiveWallet()
    
    private init() {}
    
    internal func handle(body: SetActiveWalletBody) {
        switch body.wallet {
            
        case .user(let userWalletBody):
            let userWallet = UserWallet(address: userWalletBody.address, authToken: userWalletBody.authToken, refreshToken: userWalletBody.refreshToken)
            WalletUseCases.shared.setActiveWallet(user: userWallet)
            
        case .guest(let guestWalletBody):
            WalletUseCases.shared.getGuestWallet { result in
                switch result {
                case .success(let guestWallet):
                    WalletUseCases.shared.setActiveWallet(guest: guestWallet)
                case .failure(let failure):
                    return
                }
            }
            
        }
    }
}
