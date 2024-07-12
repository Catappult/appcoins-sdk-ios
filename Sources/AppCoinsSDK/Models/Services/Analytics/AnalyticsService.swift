//
//  AnalyticsService.swift
//
//
//  Created by Graciano Caldeira on 09/07/2024.
//

import Foundation

internal protocol AnalyticsService {
    func initialize(userProperties: AnalyticsUserProperties, environment: String)
    func recordPurchaseIntent(paymentMethod: String)
    func recordPaymentStatus(status: String)
    func recordStartConnection()
}
