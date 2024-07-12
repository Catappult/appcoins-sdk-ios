//
//  IndicativeAnalyticsClient.swift
//
//
//  Created by Graciano Caldeira on 09/07/2024.
//

import Foundation
import IndicativeLibrary

internal class IndicativeAnalyticsClient: AnalyticsService {
    
    internal func initialize(userProperties: AnalyticsUserProperties, environment: String) {
        Indicative.launch(Connect.shared.get(environment: environment))
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
