//
//  OnPurchaseResult.swift
//
//
//  Created by aptoide on 04/04/2025.
//

import Foundation

internal class OnPurchaseResult {
    
    internal static let shared = OnPurchaseResult()
    
    private init() {}
    
    internal func handle(body: OnPurchaseResultBody) {
        if let wallet = body.wallet {
            setActiveWallet(wallet: wallet) {
                self.verifyPurchase(
                    domain: body.purchaseData.packageName,
                    purchaseToken: body.purchaseData.purchaseToken,
                    orderId: body.purchaseData.orderId
                )
            }
        } else {
            Utils.log("No wallet found at OnPurchaseResult.swift:handle")
            self.verifyPurchase(
                domain: body.purchaseData.packageName,
                purchaseToken: body.purchaseData.purchaseToken,
                orderId: body.purchaseData.orderId
            )
        }
    }
    
    internal func handle(query: OnPurchaseResultQuery) {
        if let wallet = query.wallet {
            setActiveWallet(wallet: wallet) {
                self.verifyPurchase(
                    domain: query.purchaseData.packageName,
                    purchaseToken: query.purchaseData.purchaseToken,
                    orderId: query.purchaseData.orderId
                )
            }
        } else {
            Utils.log("No wallet found at OnPurchaseResult.swift:handle")
            self.verifyPurchase(
                domain: query.purchaseData.packageName,
                purchaseToken: query.purchaseData.purchaseToken,
                orderId: query.purchaseData.orderId
            )
        }
    }
    
    private func verifyPurchase(domain: String, purchaseToken: String, orderId: String) {
        if #available(iOS 26, *) {
            ExternalPurchaseUseCases.shared.associateTransaction(transactionUID: orderId)
        }
        
        Purchase.verify(domain: domain, purchaseUID: purchaseToken) {
            result in
            switch result {
            case .success(let purchase):
                purchase.acknowledge(domain: domain) {
                    error in
                    if let error = error {
                        PurchaseViewModel.shared.failed(error: error)
                    } else {
                        PurchaseViewModel.shared.success(verificationResult: .verified(purchase: purchase))
                    }
                }
            case .failure(let error):
                PurchaseViewModel.shared.failed(error: error)
            }
        }
    }
    
    private func setActiveWallet(wallet: OnPurchaseResultBody.Wallet, completion: @escaping () -> Void) {
        if let user = wallet.user {
            let userWallet = UserWallet(address: user.address, authToken: user.authToken, refreshToken: user.refreshToken)
            WalletUseCases.shared.setActiveWallet(user: userWallet)
            completion()
        } else if let guest = wallet.guest {
            WalletUseCases.shared.getGuestWallet { result in
                switch result {
                case .success(let guestWallet):
                    WalletUseCases.shared.setActiveWallet(guest: guestWallet)
                    completion()
                case .failure(let failure):
                    return
                }
            }
        }
    }
    
    private func setActiveWallet(wallet: OnPurchaseResultQuery.Wallet, completion: @escaping () -> Void) {
        switch wallet {
            case .user(let userWalletQuery):
                let userWallet = UserWallet(address: userWalletQuery.address, authToken: userWalletQuery.authToken, refreshToken: userWalletQuery.refreshToken)
                WalletUseCases.shared.setActiveWallet(user: userWallet)
                completion()
                
            case .guest(let guestWalletQuery):
                WalletUseCases.shared.getGuestWallet { result in
                    switch result {
                    case .success(let guestWallet):
                        WalletUseCases.shared.setActiveWallet(guest: guestWallet)
                        completion()
                    case .failure(let failure):
                        return
                    }
                }
        }
    }
}
