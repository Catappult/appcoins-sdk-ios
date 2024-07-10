//
//  File.swift
//  
//
//  Created by Graciano Caldeira on 09/07/2024.
//

import Foundation

class AnalyticsRepository: AnalyticsRepositoryProtocol {
    
    private let AnalyticsService: AnalyticsService = IndicativeAnalyticsClient()
    
    func initialize() { AnalyticsService.initialize() }
    func recordEvent() {}
    func recordUserFlow() {}
}
