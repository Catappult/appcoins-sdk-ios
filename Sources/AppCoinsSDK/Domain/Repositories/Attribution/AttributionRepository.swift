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
        
        // Check if request has already been triggered
        if guestUID == nil {
            self.AttributionService.getAttribution(bundleID: BuildConfiguration.packageName) { result in
                switch result {
                case .success(let attributionRaw):
                    UserDefaults.standard.set(String(attributionRaw.guestUID), forKey: "attribution-guestuid")
                    
                    if let rawOemID = attributionRaw.oemID, rawOemID != "" { UserDefaults.standard.set(rawOemID, forKey: "attribution-oemid") }
                case .failure: break
                }
            }
        }
        
    }
}
