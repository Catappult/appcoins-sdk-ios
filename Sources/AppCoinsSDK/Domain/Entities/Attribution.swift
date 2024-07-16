//
//  Attribution.swift
//  
//
//  Created by Graciano Caldeira on 15/07/2024.
//

import Foundation

internal struct Attribution: Codable {
    
    let package: String?
    let oemID: String?
    let guestUID: String
    
    init(_ attribution: AttributionRaw) {
        self.package = attribution.package
        self.oemID = attribution.oemID
        self.guestUID = attribution.guestUID
    }
}
