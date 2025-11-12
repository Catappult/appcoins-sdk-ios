//
//  UserWallet.swift
//
//
//  Created by aptoide on 16/12/2024.
//

import Foundation

internal class UserWallet: Wallet, Codable {
    
    internal let address: String
    internal let authToken: String
    internal let refreshToken: String
    internal let added: Date
    
    internal init(address: String, authToken: String, refreshToken: String) {
        self.address = address
        self.authToken = authToken
        self.refreshToken = refreshToken
        self.added = Date()
    }
    
    internal init(raw: UserWalletRaw) {
        self.address = raw.address
        self.authToken = raw.authToken
        self.refreshToken = raw.refreshToken
        self.added = Date()
    }

    internal func getWalletAddress() -> String {
        Utils.log(
            "UserWallet.getWalletAddress() at UserWallet.swift",
            category: "Lifecycle",
            level: .info
        )
        
        return self.address
    }
    
    internal func getAuthToken() -> String? {
        Utils.log(
            "UserWallet.getAuthToken() at UserWallet.swift",
            category: "Lifecycle",
            level: .info
        )
        
        return "Bearer \(self.authToken)"
    }
    
    internal func isExpired() -> Bool {
        let minutesLived = -self.added.timeIntervalSinceNow / 60
        return minutesLived > 10 // Is expired if it was fetched more than 10 minutes ago
    }
    
    // Conform to Codable Protocol
    internal enum CodingKeys: String, CodingKey {
            case address
            case authToken
            case refreshToken
            case added
        }
        
    internal required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(String.self, forKey: .address)
        authToken = try container.decode(String.self, forKey: .authToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        added = try container.decode(Date.self, forKey: .added)
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(authToken, forKey: .authToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(added, forKey: .added)
    }
}
