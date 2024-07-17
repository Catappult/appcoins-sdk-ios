//
//  AttributionRaw.swift
//
//
//  Created by Graciano Caldeira on 16/07/2024.
//

import Foundation

internal struct AttributionRaw: Codable {
    
    let package: String?
    let oemID: String?
    let guestUID: String
    
    enum CodingKeys: String, CodingKey {
        case package = "package_name"
        case oemID = "oemid"
        case guestUID = "guest_uid"
    }
}
