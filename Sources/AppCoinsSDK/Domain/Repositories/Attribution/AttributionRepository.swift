//
//  File.swift
//  
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal class AttributionRepository: AttributionRepositoryProtocol {
    
    private let AttributionService: AttributionService = AttributionClient()
    private var GuestUIDCache: Cache<String, Attribution> = Cache(cacheName: "Attribution")
    
    internal func getAttribution(completion: @escaping (Result<Attribution, Error>) -> Void) {
        if let attribution = self.GuestUIDCache.getValue(forKey: "attribution") {
            completion(.success(attribution))
        } else {
            self.AttributionService.getAttribution(bundleID: Bundle.main.bundleIdentifier ?? "") { result in
                switch result {
                case .success(let attributionRaw):
                    self.GuestUIDCache.setValue(Attribution(attributionRaw), forKey: "attribution", storageOption: .memory)
                    completion(.success(Attribution(attributionRaw)))
                case .failure:
                    break
                }
            }
        }
    }
}
