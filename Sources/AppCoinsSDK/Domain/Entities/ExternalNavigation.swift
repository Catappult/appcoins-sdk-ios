//
//  ExternalNavigation.swift
//  
//
//  Created by aptoide on 07/04/2025.
//

import Foundation

internal struct ExternalNavigation: Codable {
    
    internal let externalURLs: [String]
    internal let externalAuthenticationURLs: [String]
    
    internal init(raw: SetExternalNavigationBody) {
        self.externalURLs = raw.externalURLs
        self.externalAuthenticationURLs = raw.externalAuthenticationURLs
    }
    
}
