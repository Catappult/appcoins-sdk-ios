//
//  SetNavigationBody.swift
//
//
//  Created by aptoide on 07/04/2025.
//

import Foundation

internal struct SetNavigationBody: Codable {
    
    internal let externalURLs: [String]
    internal let externalAuthenticationURLs: [String]
    
    internal enum CodingKeys: String, CodingKey {
        case externalURLs = "externalURLs"
        case externalAuthenticationURLs = "externalAuthenticationURLs"
    }
}
