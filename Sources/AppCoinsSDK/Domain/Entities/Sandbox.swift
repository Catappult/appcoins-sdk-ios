//
//  Sandbox.swift
//  
//
//  Created by aptoide on 16/02/2024.
//

import Foundation

public struct Sandbox {
    
    // This method should be accessed by developers for testing purposes only
    // This method should be accessed by developers for testing purposes only
    static public func getTestingWalletAddress() -> String? {
        return WalletUseCases.shared.getClientWallet()?.getWalletAddress()
    }
    
}
