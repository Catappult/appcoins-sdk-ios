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
        self.verifyPurchase(domain: body.purchaseData.packageName, purchaseToken: body.purchaseData.purchaseToken)
    }
    
    internal func handle(query: OnPurchaseResultQuery) {
        if let wallet = query.wallet {
            setActiveWallet(wallet: wallet) {
                self.verifyPurchase(domain: query.purchaseData.packageName, purchaseToken: query.purchaseData.purchaseToken)
            }
        } else {
            Utils.log("No wallet OnPurchaseResultQuery")
            self.verifyPurchase(domain: query.purchaseData.packageName, purchaseToken: query.purchaseData.purchaseToken)
        }
    }
    
    private func verifyPurchase(domain: String, purchaseToken: String) {
        Purchase.verify(domain: domain, purchaseUID: purchaseToken) {
            result in
            switch result {
            case .success(let purchase):
                Utils.log("Purchase verified with success")
                purchase.acknowledge(domain: domain) {
                    error in
                    if let error = error {
                        Utils.log("Failed to acknowledge purchase")
                        PurchaseViewModel.shared.failed(error: error)
                    } else {
                        Utils.log("Purchase acknowledged and transaction succeeded")
                        PurchaseViewModel.shared.success(verificationResult: .verified(purchase: purchase))
                    }
                }
            case .failure(let error):
                Utils.log("Failed to verify purchase")
                Utils.log(error.description)
                PurchaseViewModel.shared.failed(error: error)
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
