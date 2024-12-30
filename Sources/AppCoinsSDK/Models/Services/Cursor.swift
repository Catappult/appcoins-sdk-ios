//
//  Cursor.swift
//
//
//  Created by aptoide on 30/12/2024.
//

import Foundation

internal struct Cursor: Codable {
    let cursor: String
    let query: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case cursor = "cursor"
        case query = "query"
        case url = "url"
    }
}
