//
//  AttributionRepository.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal class AttributionRepository: AttributionRepositoryProtocol {
    
    private let AttributionService: AttributionService = AttributionClient()
    
    internal func getAttribution() {
        
        let oemID = UserDefaults.standard.string(forKey: "attribution-oemid")
        let guestUID = UserDefaults.standard.string(forKey: "attribution-guestuid")
        
        self.AttributionService.getAttribution(bundleID: BuildConfiguration.packageName, oemID: oemID, guestUID: guestUID) { result in
            switch result {
            case .success(let attributionRaw):
                if oemID == nil, let rawOemID = attributionRaw.oemID, rawOemID != "" { UserDefaults.standard.set(rawOemID, forKey: "attribution-oemid") }
                if guestUID == nil { UserDefaults.standard.set(String(attributionRaw.guestUID), forKey: "attribution-guestuid") }
            case .failure: break
            }
        }
    }
}
