//
//  SendMagicLinkResponseRaw.swift
//  
//
//  Created by aptoide on 13/01/2025.
//

import Foundation

internal struct SendMagicLinkResponseRaw: Codable {
    
    internal let type: String
    internal let state: String?
    internal let signup: Bool
    internal let data: SendMagicLinkResponseDataRaw
    
    internal enum CodingKeys: String, CodingKey {
        case type = "type"
        case state = "state"
        case signup = "signup"
        case data = "data"
    }
    
    internal struct SendMagicLinkResponseDataRaw: Codable {
        internal let type: String
        internal let method: String
        
        internal enum CodingKeys: String, CodingKey {
            case type = "type"
            case method = "method"
        }
    }
}
