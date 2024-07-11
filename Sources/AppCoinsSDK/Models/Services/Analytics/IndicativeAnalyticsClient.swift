//
//  IndicativeAnalyticsClient.swift
//
//
//  Created by Graciano Caldeira on 09/07/2024.
//

import Foundation
import IndicativeLibrary

class IndicativeAnalyticsClient: AnalyticsService {
    
    func initialize(userProperties: AnalyticsUserProperties) {
        Indicative.launch(self.getApiKey())
        Indicative.addCommonProperties(userProperties.toDict())
    }
    
    func recordPurchaseIntent(paymentMethod: String) {
        print("paymentMethod: \(paymentMethod)")
        Indicative.record("ios_sdk_iap_purchase_intent_click", withProperties: ["paymentMethod": paymentMethod])
    }
    
    func recordPaymentStatus(status: String) {
        Indicative.record("ios_sdk_iap_payment_status_feedback", withProperties: ["paymentStatus": status])
    }
    
    func recordStartConnection() {
        Indicative.record("ios_sdk_start_connection")
    }
    
    func getApiKey() -> String {
        switch BuildConfiguration.environment {
        case .debugSDKDev, .releaseSDKDev:
            return Keys.apiDev
        case .debugSDKProd, .releaseSDKProd:
            return Keys.apiProd
        }
    }
}
