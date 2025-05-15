//
//  AppcSDKInternal.swift
//
//
//  Created by Graciano Caldeira on 11/07/2024.
//

import Foundation

internal class AppcSDKInternal {
    
    static internal func initialize() {
        MMPUseCases.shared.getAttribution()
        AnalyticsUseCases.shared.initialize()
        PurchaseIntentManager.shared.initialize()
    }
}
