//
//  DeleteAccountResponseRaw.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/05/2025.
//

import Foundation

internal struct DeleteAccountResponseRaw: Codable {
    
    internal let type: String
    internal let state: String?
    internal let signup: Bool
    internal let data: DeleteAccountResponseDataRaw
    
    internal enum CodingKeys: String, CodingKey {
        case type = "type"
        case state = "state"
        case signup = "signup"
        case data = "data"
    }
    
    internal struct DeleteAccountResponseDataRaw: Codable {
        internal let type: String
        internal let method: String
        
        internal enum CodingKeys: String, CodingKey {
            case type = "type"
            case method = "method"
        }
    }
}
