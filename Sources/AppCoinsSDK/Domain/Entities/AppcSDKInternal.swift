//
//  File.swift
//  
//
//  Created by Graciano Caldeira on 11/07/2024.
//

import Foundation

internal class AppcSDKInternal {
    
    static internal func initialize() {
        AnalyticsUseCases.shared.initialize()
        AttributionUseCases.shared.getAttribution { result in
            switch result {
            case .success: break
            case .failure: break
            }
        }
    }
}
