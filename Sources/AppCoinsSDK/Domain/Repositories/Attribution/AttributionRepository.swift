//
//  File.swift
//  
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal class AttributionRepository: AttributionRepositoryProtocol {
    
    private let AttributionService: AttributionService = AttributionClient()
    private var guestUID: String? = nil
    
    internal func getAttribution() {
        self.AttributionService.getAttribution(bundleID: Bundle.main.bundleIdentifier ?? "") { result in
            switch result {
            case .success(let success):
                self.guestUID = success.guestUID
            case .failure:
                break
            }
        }
    }
    
    internal func getGuestUID() -> String {
        return self.guestUID ?? ""
    }
}
