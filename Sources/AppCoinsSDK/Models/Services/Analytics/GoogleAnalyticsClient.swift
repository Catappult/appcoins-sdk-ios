//
//  GoogleAnalyticsClient.swift
//
//
//  Created by aptoide on 07/03/2025.
//

import Foundation

internal class GoogleAnalyticsClient: AnalyticsService {
    
    private var userProperties: [AnyHashable: Any] = [:]
    private let clientID = BuildConfiguration.userUID
    private let sessionID = UUID()
    
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
    
    private func sendEvent(name: String, parameters: [String: Any]? = nil, debugMode: Bool = false) {
        let defaultParams: [String: Any] = [
            "session_id": sessionID.uuidString,
            // Required by GA4: indicates how long the user was "engaged" before the event.
            // GA4 uses this to determine active user status and engagement metrics, and may discard events with missing or implausible values.
            // Since we’re not tracking actual engagement time, we default to 1000ms (1 second) as a plausible baseline.
            "engagement_time_msec": 1000,
            "debug_mode": debugMode
        ]
        
        let mergedParams = (parameters ?? [:]).merging(defaultParams) { _, new in new }
        
        var eventData: [String: Any] = [
            "client_id": clientID,
            "events": [
                [
                    "name": name,
                    "params": mergedParams
                ]
            ],
            "user_properties": formatUserPropertiesForGA4(userProperties: userProperties)
        ]
        
        googleAnalyticsMeasurementService.sendEvent(eventData: eventData)
    }
    
    private func formatUserPropertiesForGA4(userProperties: [AnyHashable: Any]) -> [String: [String: Any]] {
        var formatted: [String: [String: Any]] = [:]
        
        for (key, value) in userProperties {
            guard let stringKey = key as? String else { continue }
            formatted[stringKey] = ["value": value]
        }
        
        return formatted
    }
    
}
