//
//  ConfirmDeleteAccountResponseRaw.swift
//
//
//  Created by aptoide on 13/01/2025.
//

import Foundation

internal struct ConfirmDeleteAccountResponseRaw: Codable {
    
    internal let type: String
    internal let state: String?
    internal let signup: Bool
    
    internal enum CodingKeys: String, CodingKey {
        case type = "type"
        case state = "state"
        case signup = "signup"
    }
}
