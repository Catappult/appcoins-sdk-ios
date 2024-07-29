//
//  AppcSDKInternal.swift
//
//
//  Created by Graciano Caldeira on 11/07/2024.
//

import Foundation

internal class AppcSDKInternal {
    
    static internal func initialize() {
        DispatchQueue.global(qos: .background).async {
            MMPUseCases.shared.getAttribution { PayFlowUseCases.shared.setPayFlow() }
        }
        AnalyticsUseCases.shared.initialize()
    }
}
