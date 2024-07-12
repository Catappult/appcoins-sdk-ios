//
//  AnalyticsRepositoryProtocol.swift
//  
//
//  Created by Graciano Caldeira on 09/07/2024.
//

import Foundation

internal protocol AnalyticsRepositoryProtocol {
    
    func initialize()
    func recordPurchaseIntent(paymentMethod: String)
    func recordStartConnection()
    func recordPaymentStatus(status: String)
    
}
