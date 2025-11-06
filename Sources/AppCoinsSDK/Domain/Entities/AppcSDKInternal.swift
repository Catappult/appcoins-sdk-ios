//
//  AppcSDKInternal.swift
//
//
//  Created by Graciano Caldeira on 11/07/2024.
//

import Foundation

internal class AppcSDKInternal {
    
    static internal func initialize() {
        Utils.log(
            "AppcSDKInternal.initialize() at AppcSDKInternal.swift",
            category: "Lifecycle",
            level: .info
        )
        
        SDKUseCases.shared.setSDKInitialized()
        MMPUseCases.shared.getAttribution()
        AnalyticsUseCases.shared.initialize()
        PurchaseIntentManager.shared.initialize()
    }
}
