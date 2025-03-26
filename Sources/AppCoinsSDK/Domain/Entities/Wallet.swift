//
//  Wallet.swift
//  
//
//  Created by aptoide on 12/07/2024.
//

import Foundation

internal protocol Wallet: Codable {
    func getWalletAddress() -> String
    func getAuthToken() -> String?
}
