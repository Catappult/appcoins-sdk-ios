//
//  GuestWallet.swift
//  
//
//  Created by aptoide on 12/07/2024.
//

import Foundation

internal class GuestWallet: Wallet, Codable {
    
    internal let guestUID: String
    internal let address: String
    internal let ewt: String
    internal let signature: String?
    
    internal init(guestUID: String, address: String, ewt: String, signature: String) {
        self.guestUID = guestUID
        self.address = address
        self.ewt = ewt
        self.signature = signature
    }
    
    internal init(guestUID: String, raw: GuestWalletRaw) {
        self.guestUID = guestUID
        self.address = raw.address
        self.ewt = raw.ewt
        self.signature = raw.signature
    }
    
    internal func getWalletAddress() -> String { return self.address }
    
    internal func getSignedWalletAddress() -> String? { return self.signature }
    
    internal func getAuthToken() -> String? { return "Bearer \(self.ewt)" }
    
    // Conform to Codable Protocol
    internal enum CodingKeys: String, CodingKey {
        case guestUID
        case address
        case ewt
        case signature
    }
        
    internal required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guestUID = try container.decode(String.self, forKey: .guestUID)
        address = try container.decode(String.self, forKey: .address)
        ewt = try container.decode(String.self, forKey: .ewt)
        signature = try container.decode(String.self, forKey: .signature)
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(guestUID, forKey: .guestUID)
        try container.encode(address, forKey: .address)
        try container.encode(ewt, forKey: .ewt)
        try container.encode(signature, forKey: .signature)
    }
}
