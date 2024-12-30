//
//  AttributionRaw.swift
//
//
//  Created by Graciano Caldeira on 16/07/2024.
//

import Foundation

internal struct AttributionRaw: Codable {
    
    internal let package: String?
    internal let oemID: String?
    internal let guestUID: String
    
    internal enum CodingKeys: String, CodingKey {
        case package = "package_name"
        case oemID = "oemid"
        case guestUID = "guest_uid"
    }
}
