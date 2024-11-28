//
//  File.swift
//  
//
//  Created by aptoide on 28/11/2024.
//

import Foundation

internal struct UserAuthRaw: Codable {
    
    internal let credential: String
    internal let type: String
    internal let supported: String
    internal let agent: String?
    
    internal enum CodingKeys: String, CodingKey {
        case credential = "credential"
        case type = "type"
        case supported = "supported"
        case agent = "agent"
    }
    
    internal static func fromGoogleAuth(token: String) -> UserAuthRaw {
        return UserAuthRaw(credential: token, type: UserAuthType.Google.rawValue, supported: UserAuthSupported.OAuth2.rawValue, agent: nil)
    }
    
    internal func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

internal enum UserAuthType: String {
    case Google = "GOOGLE"
}

internal enum UserAuthSupported: String {
    case EWT = "EWT"
    case Code = "CODE"
    case OAuth2 = "OAUTH2"
}
