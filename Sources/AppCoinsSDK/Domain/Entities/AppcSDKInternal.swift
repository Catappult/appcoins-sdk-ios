//
//  AppcSDKInternal.swift
//
//
//  Created by Graciano Caldeira on 11/07/2024.
//

import Foundation

internal class AppcSDKInternal {
    
    static internal func initialize() {
        SDKUseCases.shared.setSDKInitialized()
        MMPUseCases.shared.getAttribution()
        AnalyticsUseCases.shared.initialize()
        PurchaseIntentManager.shared.initialize()
    }
}
