//
//  AnalyticsUseCases.swift
//  
//
//  Created by Graciano Caldeira on 09/07/2024.
//

import Foundation

internal class AnalyticsUseCases {
    
    static let shared = AnalyticsUseCases()
    private var repository: AnalyticsRepositoryProtocol
    
    private init(repository: AnalyticsRepositoryProtocol = AnalyticsRepository()) {
        self.repository = repository
    }
    
    internal func initialize() { repository.initialize() }
    
    internal func recordPurchaseIntent(paymentMethod: String) { repository.recordPurchaseIntent(paymentMethod: paymentMethod) }
    
    internal func recordStartConnection() { repository.recordStartConnection() }
    
    internal func recordPaymentStatus(status: String) { repository.recordPaymentStatus(status: status) }
}
