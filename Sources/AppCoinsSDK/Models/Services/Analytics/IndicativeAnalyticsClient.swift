//
//  IndicativeAnalyticsClient.swift
//
//
//  Created by Graciano Caldeira on 09/07/2024.
//

import Foundation
import IndicativeLibrary

internal class IndicativeAnalyticsClient: AnalyticsService {
    
    internal let dev: [UInt8] = [57, 100, 122, 101, 117, 80, 56, 108, 120, 121, 101, 115, 77, 68, 108, 52, 115, 114, 53, 89, 73,
                                 67, 77, 57, 71, 66, 71, 108, 50, 77, 112, 102, 108, 72, 106, 79, 47, 51, 78, 86, 69, 89, 111, 79, 66,
                                 85, 104, 83, 54, 114, 50, 108, 80, 73, 85, 83, 54, 81, 87, 86, 99, 103, 122, 89, 115, 50, 115, 77, 53,
                                 98, 85, 86, 77, 103, 51, 74, 82, 109, 68, 68, 74, 75, 82, 69, 67, 103, 61, 61]
    internal let prod: [UInt8] = [88, 83, 68, 54, 66, 73, 102, 101, 105, 57, 57, 84, 112, 107, 117, 67, 73, 100, 83, 53, 90, 114, 99,
                                  113, 85, 107, 47, 51, 115, 89, 79, 113, 74, 90, 52, 77, 119, 116, 79, 112, 122, 107, 119, 114, 69,
                                  102, 66, 82, 73, 82, 98, 47, 81, 116, 76, 119, 80, 53, 56, 97, 116, 117, 69, 84, 119, 65, 80, 53,
                                  51, 108, 110, 66, 67, 98, 114, 87, 81, 119, 122, 120, 83, 77, 108, 77, 74, 81, 61, 61]
    
    internal func initialize(userProperties: AnalyticsUserProperties) {
        switch BuildConfiguration.environment {
        case .debugSDKDev, .releaseSDKDev:
            Indicative.launch(Maze.shared.get(key: self.dev))
        case .debugSDKProd, .releaseSDKProd:
            Indicative.launch(Maze.shared.get(key: self.prod))
        }
        Indicative.addCommonProperties(userProperties.toDict())
    }
    
    internal func recordPurchaseIntent(paymentMethod: String) {
        Indicative.record("ios_sdk_iap_purchase_intent_click", withProperties: ["paymentMethod": paymentMethod])
    }
    
    internal func recordPaymentStatus(status: String) {
        Indicative.record("ios_sdk_iap_payment_status_feedback", withProperties: ["paymentStatus": status])
    }
    
    internal func recordStartConnection() {
        Indicative.record("ios_sdk_start_connection")
    }
}
