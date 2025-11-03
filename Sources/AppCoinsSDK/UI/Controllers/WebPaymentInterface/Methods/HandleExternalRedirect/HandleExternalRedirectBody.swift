//
//  HandleExternalRedirectBody.swift
//
//
//  Created by aptoide on 10/04/2025.
//

import Foundation

internal struct HandleExternalRedirectBody: Codable {
    
    internal let URL: String
    
    internal enum CodingKeys: String, CodingKey {
        case URL = "URL"
    }
}
