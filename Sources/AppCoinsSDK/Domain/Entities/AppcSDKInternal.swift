//
//  AppcSDKInternal.swift
//
//
//  Created by Graciano Caldeira on 11/07/2024.
//

import Foundation

internal class AppcSDKInternal {
    
    static internal func initialize() {
        AnalyticsUseCases.shared.initialize()
        MMPUseCases.shared.getAttribution { PayFlowUseCases.shared.setPayFlow() }
    }
}
