//
//  SetWebDeepLinksBody.swift
//  
//
//  Created by aptoide on 08/04/2025.
//

import Foundation

internal struct SetWebDeepLinksBody: Codable {
    
    internal let links: [String]
    
    internal enum CodingKeys: String, CodingKey {
        case links = "links"
    }
    
}
