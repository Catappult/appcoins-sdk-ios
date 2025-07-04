//
//  UserAuthRaw.swift
//  
//
//  Created by aptoide on 28/11/2024.
//

import Foundation

internal struct UserAuthRaw: Codable {
    
    internal let credential: String
    internal let type: String
    internal let supported: String
    internal let state: String?
    internal let agent: String?
    internal let accepted: [String]
    internal let domain: String?
    internal let channel: String?
    internal let consents: [String]
    internal let action: String?
    
    internal enum CodingKeys: String, CodingKey {
        case credential = "credential"
        case type = "type"
        case supported = "supported"
        case state = "state"
        case agent = "agent"
        case accepted = "accepted"
        case domain = "domain"
        case channel = "channel"
        case consents = "consents"
        case action = "action"
    }
    
    internal static func fromGoogleAuth(code: String, acceptedTC: Bool, consents: [String]) -> UserAuthRaw {
        return UserAuthRaw(
            credential: code,
            type: UserAuthType.Google.rawValue,
            supported: UserAuthSupported.WalletJWT.rawValue,
            state: nil,
            agent: nil,
            accepted: acceptedTC ? ["TOS", "PRIVACY", "DISTRIBUTION"] : [],
            domain: Bundle.main.bundleIdentifier,
            channel: "IOS",
            consents: consents,
            action: nil
        )
    }
    
    internal static func fromMagicLinkCode(code: String, state: String, acceptedTC: Bool, consents: [String]) -> UserAuthRaw {
        return UserAuthRaw(
            credential: code,
            type: UserAuthType.Code.rawValue,
            supported: UserAuthSupported.WalletJWT.rawValue,
            state: state,
            agent: nil,
            accepted: acceptedTC ? ["TOS", "PRIVACY", "DISTRIBUTION"] : [],
            domain: Bundle.main.bundleIdentifier,
            channel: "IOS",
            consents: consents,
            action: nil
        )
    }
    
    internal static func fromMagicLinkEmail(email: String, acceptedTC: Bool) -> UserAuthRaw {
        return UserAuthRaw(
            credential: email,
            type: UserAuthType.Email.rawValue,
            supported: UserAuthSupported.Code.rawValue,
            state: nil,
            agent: nil,
            accepted: acceptedTC ? ["TOS", "PRIVACY", "DISTRIBUTION"] : [],
            domain: Bundle.main.bundleIdentifier,
            channel: "IOS",
            consents: [],
            action: nil
        )
    }
    
    internal static func fromDeleteAccountEmail(email: String) -> UserAuthRaw {
        return UserAuthRaw(
            credential: email,
            type: UserAuthType.Email.rawValue,
            supported: UserAuthSupported.Code.rawValue,
            state: nil,
            agent: nil,
            accepted: ["TOS", "PRIVACY", "DISTRIBUTION"],
            domain: Bundle.main.bundleIdentifier,
            channel: "IOS",
            consents: [],
            action: "ANONYMIZE"
        )
    }
    
    internal static func fromConfirmDeleteAccountCode(code: String, state: String) -> UserAuthRaw {
        return UserAuthRaw(
            credential: code,
            type: UserAuthType.Code.rawValue,
            supported: UserAuthSupported.WalletJWT.rawValue,
            state: state,
            agent: nil,
            accepted: ["TOS", "PRIVACY", "DISTRIBUTION"],
            domain: Bundle.main.bundleIdentifier,
            channel: "IOS",
            consents: [],
            action: "ANONYMIZE"
        )
    }
    
    internal func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    internal enum UserAuthType: String {
        case Code = "CODE"
        case Email = "EMAIL"
        case Google = "GOOGLE"
    }

    internal enum UserAuthSupported: String {
        case WalletJWT = "WALLETJWT"
        case Code = "CODE:TOKEN:EMAIL"
        case OAuth2 = "OAUTH2"
    }
}
