//
//  GuestWallet.swift
//  
//
//  Created by aptoide on 12/07/2024.
//

import Foundation

internal class GuestWallet: Wallet, Codable {
    
    internal let address: String
    internal let ewt: String
    internal let signature: String
    
    internal init(address: String, ewt: String, signature: String) {
        self.address = address
        self.ewt = ewt
        self.signature = signature 
    }
    
    internal func getWalletAddress() -> String { return self.address }
    
    internal func getSignedWalletAddress() -> String { return self.signature }
    
    internal func getAuthToken() -> String? { return "Bearer \(self.ewt)" }
    
    // Conform to Codable Protocol
    internal enum CodingKeys: String, CodingKey {
            case address
            case ewt
            case signature
        }
        
    internal required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(String.self, forKey: .address)
        ewt = try container.decode(String.self, forKey: .ewt)
        signature = try container.decode(String.self, forKey: .signature)
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(ewt, forKey: .ewt)
        try container.encode(signature, forKey: .signature)
    }
}
