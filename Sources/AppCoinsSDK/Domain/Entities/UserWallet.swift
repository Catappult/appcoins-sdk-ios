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
    internal let expiresAt: Int?

    internal init(address: String, authToken: String, refreshToken: String, expiresAt: Int? = nil) {
        self.address = address
        self.authToken = authToken
        self.refreshToken = refreshToken
        self.added = Date()
        self.expiresAt = expiresAt
    }

    internal init(raw: UserWalletRaw) {
        self.address = raw.address
        self.authToken = raw.authToken
        self.refreshToken = raw.refreshToken
        self.added = Date()
        self.expiresAt = raw.expiresAt
    }

    internal func getWalletAddress() -> String {
        Utils.log(
            "UserWallet.getWalletAddress() at UserWallet.swift",
            category: "Lifecycle",
            level: .default
        )

        return self.address
    }

    internal func getAuthToken() -> String? {
        Utils.log(
            "UserWallet.getAuthToken() at UserWallet.swift",
            category: "Lifecycle",
            level: .default
        )

        return "Bearer \(self.authToken)"
    }

    internal func isExpired() -> Bool {
        if let expiresAt = expiresAt {
            return Int(Date().timeIntervalSince1970) >= expiresAt
        }
        let minutesLived = -self.added.timeIntervalSinceNow / 60
        return minutesLived > 10
    }

    // Conform to Codable Protocol
    internal enum CodingKeys: String, CodingKey {
        case address
        case authToken
        case refreshToken
        case added
        case expiresAt
    }

    internal required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(String.self, forKey: .address)
        authToken = try container.decode(String.self, forKey: .authToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        added = try container.decode(Date.self, forKey: .added)
        expiresAt = try container.decodeIfPresent(Int.self, forKey: .expiresAt)
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(authToken, forKey: .authToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(added, forKey: .added)
        try container.encodeIfPresent(expiresAt, forKey: .expiresAt)
    }
}
