//
//  AnalyticsUseCases.swift
//  
//
//  Created by Graciano Caldeira on 09/07/2024.
//

import Foundation

class AnalyticsUseCases {
    
    static let shared = AnalyticsUseCases()
    private var repository: AnalyticsRepositoryProtocol
    
    init(repository: AnalyticsRepositoryProtocol = AnalyticsRepository()) {
        self.repository = repository
    }
    
    internal func initialize() { repository.initialize() }
    
    internal func recordPurchaseIntent() { repository.recordPurchaseIntent() }
    
    internal func recordStartConnection() { repository.recordStartConnection() }
}
