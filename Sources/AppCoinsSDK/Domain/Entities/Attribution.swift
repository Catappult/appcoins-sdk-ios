//
//  Attribution.swift
//
//
//  Created by Graciano Caldeira on 16/07/2024.
//

import Foundation

internal struct Attribution: Codable {
    
    let package: String?
    let oemID: String?
    let guestUID: String
    
    internal init(_ attributionRaw: AttributionRaw) {
        self.package = attributionRaw.package
        self.oemID = attributionRaw.oemID
        self.guestUID = attributionRaw.guestUID
    }
}
