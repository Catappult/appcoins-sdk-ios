//
//  AttributionUseCases.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal class AttributionUseCases {
    
    internal static let shared: AttributionUseCases = AttributionUseCases()
    private let repository: AttributionRepositoryProtocol
    
    internal init(repository: AttributionRepositoryProtocol = AttributionRepository()) {
        self.repository = repository
    }
    
    internal func getAttribution() { repository.getAttribution() }
    internal func getGuestUID() -> String { repository.getGuestUID() }
    
}