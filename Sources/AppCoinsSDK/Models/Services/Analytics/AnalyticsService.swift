//
//  File.swift
//  
//
//  Created by Graciano Caldeira on 09/07/2024.
//

import Foundation

protocol AnalyticsService {
    func initialize()
    func recordPurchaseIntent()
    func recordPaymentStatus(status: String)
    func recordUnexpectedFailure()
}
