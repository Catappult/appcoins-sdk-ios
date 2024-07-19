//
//  File.swift
//  
//
//  Created by aptoide on 12/07/2024.
//

import Foundation

internal struct GuestWalletRaw: Codable {
    
    internal let address: String
    internal let ewt: String?
    internal let signature: String?
    
    internal enum CodingKeys: String, CodingKey {
        case address = "address"
        case ewt = "ewt"
        case signature = "signature"
    }
}
