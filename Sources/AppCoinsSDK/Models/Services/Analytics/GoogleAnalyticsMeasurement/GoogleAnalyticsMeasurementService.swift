//
//  GoogleAnalyticsMeasurementService.swift
//
//
//  Created by aptoide on 07/03/2025.
//

import Foundation

internal protocol GoogleAnalyticsMeasurementService {
    
    func sendEvent(eventData: [String: Any])
    
}
