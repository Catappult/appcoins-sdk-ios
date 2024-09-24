//
//  AttributionRepository.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal class MMPRepository: MMPRepositoryProtocol {
    
    private let MMPService: MMPService = MMPClient()
    
    internal func getAttribution() {
        
        let oemID = UserDefaults.standard.string(forKey: "attribution-oemid")
        let guestUID = UserDefaults.standard.string(forKey: "attribution-guestuid")
        
        // Check if request has already been triggered
        if guestUID == nil {
            self.MMPService.getAttribution(bundleID: Bundle.main.bundleIdentifier ?? "") { result in
                switch result {
                case .success(let attributionRaw):
                    UserDefaults.standard.set(String(attributionRaw.guestUID), forKey: "attribution-guestuid")
                    
                    if let rawOemID = attributionRaw.oemID, rawOemID != "" { UserDefaults.standard.set(rawOemID, forKey: "attribution-oemid") }
                case .failure: break
                }
            }
        }
    }
    
    internal func getGuestUID() -> String? {
        if let guestUID = UserDefaults.standard.string(forKey: "attribution-guestuid") { return guestUID }
        return nil
    }
    
    internal func getOEMID() -> String? {
        if let oemID = UserDefaults.standard.string(forKey: "attribution-oemid") { return oemID }
        else { return BuildConfiguration.aptoideOEMID }
    }
}
