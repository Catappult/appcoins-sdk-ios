//
//  UserWalletRaw.swift
//  
//
//  Created by aptoide on 18/12/2024.
//

import Foundation

internal struct UserWalletRaw: Codable {
    
    internal let address: String
    internal let authToken: String
    internal let refreshToken: String
    
    internal enum CodingKeys: String, CodingKey {
        case address = "address"
        case authToken = "auth_token"
        case refreshToken = "refresh_token"
    }
}
