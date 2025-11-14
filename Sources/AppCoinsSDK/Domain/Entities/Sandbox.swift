//
//  Sandbox.swift
//
//
//  Created by aptoide on 16/02/2024.
//

import Foundation

public struct Sandbox {

    // Get the Wallet Address to test payments with Sandbox
    //
    // This method should be accessed by developers for testing purposes only
    //
    // ⚠️ IMPORTANT: Every time you switch account on the checkout screen the test address
    // will change and you will need to repeat this request to get the correct address
    static public func getTestingWalletAddress() async -> String? {
        Utils.log(
            "Sandbox.getTestingWalletAddress() at Sandbox.swift",
            category: "Lifecycle",
            level: .info
        )
        
        let wallet: Wallet? = try? await withCheckedThrowingContinuation { continuation in
            WalletUseCases.shared.getWallet { result in
                switch result {
                case .success(let wallet):
                    continuation.resume(returning: wallet)
                case .failure:
                    continuation.resume(returning: nil)
                }
            }
        }
        return wallet?.getWalletAddress()
    }

}
