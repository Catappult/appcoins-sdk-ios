//
//  File.swift
//  
//
//  Created by Graciano Caldeira on 09/07/2024.
//

import Foundation

protocol AnalyticsService {
    func initialize()
    func recordEvent()
    func recordUserFlow()
}
