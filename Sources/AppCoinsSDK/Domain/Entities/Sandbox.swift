//
//  Sandbox.swift
//  
//
//  Created by aptoide on 16/02/2024.
//

import Foundation

public struct Sandbox {
    
    // This method should be accessed by developers for testing purposes only
    static public func getTestingWalletAddress() async -> String? {
        return try? await withCheckedThrowingContinuation { continuation in
            WalletUseCases.shared.getWallet() {
                result in
                
                switch result {
                case .success(let wallet):
                    continuation.resume(returning: wallet.getWalletAddress())
                case .failure(_):
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
}
