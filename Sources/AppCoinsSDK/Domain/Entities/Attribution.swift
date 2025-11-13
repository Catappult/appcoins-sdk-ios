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
        Utils.log(
            "Attribution.init() at Attribution.swift",
            category: "Lifecycle",
            level: .info
        )
        
        self.package = attributionRaw.package
        self.oemID = attributionRaw.oemID
        self.guestUID = attributionRaw.guestUID
    }
}
