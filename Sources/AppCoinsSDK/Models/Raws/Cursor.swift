//
//  Cursor.swift
//
//
//  Created by aptoide on 30/12/2024.
//

import Foundation

internal struct Cursor: Codable {
    internal let cursor: String
    internal let query: String
    internal let url: String
    
    internal enum CodingKeys: String, CodingKey {
        case cursor = "cursor"
        case query = "query"
        case url = "url"
    }
}
