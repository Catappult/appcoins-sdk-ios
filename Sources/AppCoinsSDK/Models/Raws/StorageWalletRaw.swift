//
//  StorageWalletRaw.swift
//
//
//  Created by aptoide on 11/04/2025.
//

import Foundation

internal struct StorageWalletRaw: Codable, Equatable {
    
    internal let type: WalletType
    internal let wallet: WalletBody
    
    private init(wallet: WalletBody) {
        switch wallet {
        case .guest(let storageGuestWallet):
            self.type = .guest
            self.wallet = wallet
        case .user(let storageUserWallet):
            self.type = .user
            self.wallet = wallet
        }
    }
    
    internal static func fromUser(wallet: UserWallet) -> StorageWalletRaw {
        return StorageWalletRaw(wallet: .user(StorageUserWallet(wallet: wallet)))
    }
    
    internal static func fromUser(address: String, refreshToken: String, added: Date = Date()) -> StorageWalletRaw {
        return StorageWalletRaw(wallet: .user(StorageUserWallet(address: address, refreshToken: refreshToken, added: added)))
    }
    
    internal static func fromGuest(wallet: GuestWallet) -> StorageWalletRaw {
        return StorageWalletRaw(wallet: .guest(StorageGuestWallet(wallet: wallet)))
    }
    
    internal static func fromGuest(guestUID: String) -> StorageWalletRaw {
        return StorageWalletRaw(wallet: .guest(StorageGuestWallet(guestUID: guestUID)))
    }
    
    internal enum WalletType: String, Codable {
        case guest = "GUEST_WALLET"
        case user = "USER_WALLET"
    }
    
    internal enum WalletBody: Codable {
        case guest(StorageGuestWallet)
        case user(StorageUserWallet)
        
        private enum GuestCodingKeys: String, CodingKey {
            case guestUID, address, authToken
        }
        
        private enum UserCodingKeys: String, CodingKey {
            case address, authToken, refreshToken, added
        }
        
        internal init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Decoding should occur in WalletRaw initializer")
        }
        
        internal func encode(to encoder: Encoder) throws {
            switch self {
            case .guest(let guestWallet):
                try guestWallet.encode(to: encoder)
            case .user(let userWallet):
                try userWallet.encode(to: encoder)
            }
        }
    }
    
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(WalletType.self, forKey: .type)
        switch type {
        case .guest:
            let guestWallet = try container.decode(StorageGuestWallet.self, forKey: .wallet)
            self.wallet = .guest(guestWallet)
        case .user:
            let userWallet = try container.decode(StorageUserWallet.self, forKey: .wallet)
            self.wallet = .user(userWallet)
        }
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        switch wallet {
        case .guest(let guestWallet):
            try container.encode(guestWallet, forKey: .wallet)
        case .user(let userWallet):
            try container.encode(userWallet, forKey: .wallet)
        }
    }
    
    internal enum CodingKeys: String, CodingKey {
        case type, wallet
    }

    internal struct StorageGuestWallet: Codable {
        internal let guestUID: String
        
        internal init(guestUID: String) {
            self.guestUID = guestUID
        }
        
        internal init(wallet: GuestWallet) {
            self.guestUID = wallet.guestUID
        }
    }

    internal struct StorageUserWallet: Codable {
        internal let address: String
        internal let refreshToken: String
        internal let added: Date
        
        internal init(address: String, refreshToken: String, added: Date) {
            self.address = address
            self.refreshToken = refreshToken
            self.added = added
        }
        
        internal init(wallet: UserWallet) {
            self.address = wallet.address
            self.refreshToken = wallet.refreshToken
            self.added = wallet.added
        }
    }
    
    static func == (lhs: StorageWalletRaw, rhs: StorageWalletRaw) -> Bool {
        if let lhsGuestWallet = lhs.wallet as? StorageGuestWallet, let rhsGuestWallet = rhs.wallet as? StorageGuestWallet {
            return lhsGuestWallet.guestUID == rhsGuestWallet.guestUID
        } else if let lhsUserWallet = lhs.wallet as? StorageUserWallet, let rhsUserWallet = rhs.wallet as? StorageUserWallet {
            return lhsUserWallet.address == rhsUserWallet.address
        } else {
            return false
        }
    }
}
