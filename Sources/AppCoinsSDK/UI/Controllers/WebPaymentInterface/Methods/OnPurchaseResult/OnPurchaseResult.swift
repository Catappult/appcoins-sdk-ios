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
        let domain: String = BuildConfiguration.packageName
        Purchase.verify(domain: domain, purchaseUID: body.purchaseData.purchaseToken) {
            result in
            switch result {
            case .success(let purchase):
                Utils.log("Purchase verified with success")
                purchase.acknowledge(domain: domain) {
                    error in
                    if let error = error {
                        Utils.log("Failed to acknowledge purchase")
                        PurchaseViewModel.shared.sendResult(result: .failed(error: error))
                    } else {
                        Utils.log("Purchase acknowledged and transaction succeeded")
                        PurchaseViewModel.shared.sendResult(result: .success(verificationResult: .verified(purchase: purchase)))
                    }
                }
            case .failure(let error): 
                Utils.log("Failed to verify purchase")
                PurchaseViewModel.shared.sendResult(result: .failed(error: error))
            }
        }
    }
}
