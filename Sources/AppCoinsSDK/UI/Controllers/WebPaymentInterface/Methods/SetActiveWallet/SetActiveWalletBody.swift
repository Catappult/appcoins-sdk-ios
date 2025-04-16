//
//  SetActiveWalletBody.swift
//
//
//  Created by aptoide on 11/04/2025.
//

import Foundation

internal struct SetActiveWalletBody: Codable {
    internal let type: String
    internal let wallet: WalletValue

    internal enum CodingKeys: String, CodingKey {
        case type
        case wallet
    }
    
    internal enum WalletValue {
        case user(UserWalletBody)
        case guest(GuestWalletBody)
    }
    
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "USER_WALLET":
            let userWallet = try container.decode(UserWalletBody.self, forKey: .wallet)
            wallet = .user(userWallet)
        case "GUEST_WALLET":
            let guestWallet = try container.decode(GuestWalletBody.self, forKey: .wallet)
            wallet = .guest(guestWallet)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown wallet type: \(type)")
        }
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        switch wallet {
        case .user(let userWallet):
            try container.encode(userWallet, forKey: .wallet)
        case .guest(let guestWallet):
            try container.encode(guestWallet, forKey: .wallet)
        }
    }

    internal struct UserWalletBody: Codable {
        internal let address: String
        internal let authToken: String
        internal let refreshToken: String

        internal enum CodingKeys: String, CodingKey {
            case address
            case authToken
            case refreshToken
        }
    }

    internal struct GuestWalletBody: Codable {
        internal let guestUID: String

        internal enum CodingKeys: String, CodingKey {
            case guestUID
        }
    }
}
