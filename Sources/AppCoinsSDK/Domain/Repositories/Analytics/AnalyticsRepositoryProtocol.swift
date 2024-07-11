//
//  AnalyticsRepositoryProtocol.swift
//  
//
//  Created by Graciano Caldeira on 09/07/2024.
//

import Foundation

protocol AnalyticsRepositoryProtocol {
    
    func initialize()
    func recordPurchaseIntent()
    func recordUnexpectedFailure()
    
}
