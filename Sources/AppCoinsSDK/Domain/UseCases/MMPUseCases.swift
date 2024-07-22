//
//  AttributionUseCases.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal class MMPUseCases {
    
    internal static let shared: MMPUseCases = MMPUseCases()
    private let repository: MMPRepositoryProtocol
    
    private init(repository: MMPRepositoryProtocol = MMPRepository()) {
        self.repository = repository
    }
    
    internal func getAttribution() { repository.getAttribution() }
    
    internal func getGuestUID() -> String? { return repository.getGuestUID() }
    
    internal func getOEMID() -> String? { return repository.getOEMID() }
    
}
