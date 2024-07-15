//
//  File.swift
//  
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal class AttributionRepository: AttributionRepositoryProtocol {
    
    private let AttributionService: AttributionService = AttributionClient()
    private var GuestUIDCache: Cache<String, String> = Cache(cacheName: "GuestUID")
    
    internal func getAttribution(completion: @escaping (Result<Attribution, Error>) -> Void) {
        self.AttributionService.getAttribution(bundleID: Bundle.main.bundleIdentifier ?? "") { result in
            switch result {
            case .success(let attributionRaw):
                DispatchQueue.main.async {
                    self.GuestUIDCache.setValue(attributionRaw.guestUID, forKey: "guestuid", storageOption: .memory)
                }
                completion(.success(Attribution(attributionRaw)))
            case .failure:
                break
            }
        }
    }
    
    internal func getGuestUID() -> String {
        if let guestuid = self.GuestUIDCache.getValue(forKey: "guestuid") {
            
        }
        return self.GuestUIDCache.getValue(forKey: "guestuid") ?? ""
    }
}
