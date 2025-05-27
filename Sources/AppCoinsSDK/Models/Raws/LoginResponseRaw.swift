//
//  LoginResponseRaw.swift
//
//
//  Created by aptoide on 13/01/2025.
//

import Foundation

internal struct LoginResponseRaw: Codable {
    
    internal let type: String
    internal let state: String?
    internal let signup: Bool
    internal let data: LoginResponseDataRaw
    
    internal enum CodingKeys: String, CodingKey {
        case type = "type"
        case state = "state"
        case signup = "signup"
        case data = "data"
    }
    
    internal struct LoginResponseDataRaw: Codable {
        internal let address: String
        internal let authToken: String
        internal let refreshToken: String
        internal let email: String?
        
        internal enum CodingKeys: String, CodingKey {
            case address = "address"
            case authToken = "auth_token"
            case refreshToken = "refresh_token"
            case email = "email"
        }
    }
}
