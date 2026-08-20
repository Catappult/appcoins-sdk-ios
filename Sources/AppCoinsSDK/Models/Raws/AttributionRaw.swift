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
    internal let utmSource: String?
    internal let utmMedium: String?
    internal let utmCampaign: String?
    internal let utmContent: String?
    internal let utmTerm: String?

    internal enum CodingKeys: String, CodingKey {
        case package = "package_name"
        case oemID = "oemid"
        case guestUID = "guest_uid"
        case utmSource = "utm_source"
        case utmMedium = "utm_medium"
        case utmCampaign = "utm_campaign"
        case utmContent = "utm_content"
        case utmTerm = "utm_term"
    }
}
