//
//  HandleAuthenticationRedirectBody.swift
//
//
//  Created by aptoide on 07/04/2025.
//

import Foundation

internal struct HandleAuthenticationRedirectBody: Codable {
    
    internal let URL: String
    
    internal enum CodingKeys: String, CodingKey {
        case URL = "URL"
    }
}
