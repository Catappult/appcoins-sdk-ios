//
//  IndicativeAnalyticsClient.swift
//
//
//  Created by Graciano Caldeira on 09/07/2024.
//

import Foundation
import IndicativeLibrary

class IndicativeAnalyticsClient: AnalyticsService {
    
    func initialize() {
        print("initialize called")
        print(self.getApiKey())
        Indicative.launch(self.getApiKey())
//        Indicative.record("ios_sdk_start_connection")
    }
    func recordEvent() {}
    
    func recordUserFlow() {}
    
    func getApiKey() -> String {
        switch BuildConfiguration.environment {
        case .debugSDKDev, .releaseSDKDev:
            return Keys.apiDev
        case .debugSDKProd, .releaseSDKProd:
            return Keys.apiProd
        }
    }
}
