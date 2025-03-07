//
//  File.swift
//  
//
//  Created by aptoide on 07/03/2025.
//

import Foundation

internal class GoogleAnalyticsClient: AnalyticsService {
    
    private var userProperties: [AnyHashable: Any] = [:]
    private let clientID = BuildConfiguration.userUID
    
    private let googleAnalyticsMeasurementService: GoogleAnalyticsMeasurementService = GoogleAnalyticsMeasurementServiceClient()
    
    // Initialize analytics with user properties
    internal func initialize(userProperties: AnalyticsUserProperties) {
        // Store user properties for all future events
        self.userProperties = userProperties.toDict()
    }

    // Record purchase intent
    internal func recordPurchaseIntent(paymentMethod: String) {
        sendEvent(name: "ios_sdk_iap_purchase_intent_click", parameters: ["paymentMethod": paymentMethod])
    }

    // Record payment status
    internal func recordPaymentStatus(status: String) {
        sendEvent(name: "ios_sdk_iap_payment_status_feedback", parameters: ["paymentStatus": status])
    }

    // Record connection start
    internal func recordStartConnection() {
        sendEvent(name: "ios_sdk_start_connection")
    }
    
    private func sendEvent(name: String, parameters: [String: Any]? = nil) {
        var eventData: [String: Any] = [
            "client_id": clientID,
            "events": [
                [
                    "name": name,
                    "params": parameters ?? [:]
                ]
            ],
            "user_properties": userProperties
        ]
        
        googleAnalyticsMeasurementService.sendEvent(eventData: eventData)
    }
    
}
