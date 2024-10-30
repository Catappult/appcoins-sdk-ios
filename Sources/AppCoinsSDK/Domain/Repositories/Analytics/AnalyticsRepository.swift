//
//  AnalyticsRepository.swift
//
//
//  Created by Graciano Caldeira on 09/07/2024.
//

import Foundation
@_implementationOnly import DeviceKit

internal class AnalyticsRepository: AnalyticsRepositoryProtocol {
    
    private let AnalyticsService: AnalyticsService = IndicativeAnalyticsClient()
    private var UserPropertiesCache: Cache<String, AnalyticsUserProperties> = Cache(cacheName: "UserProperties")
    
    internal func initialize() {
        AnalyticsService.initialize(userProperties: self.getUserProperties())
    }
    
    internal func recordPurchaseIntent(paymentMethod: String) {
        AnalyticsService.recordPurchaseIntent(paymentMethod: paymentMethod)
    }
    
    internal func recordStartConnection() {
        AnalyticsService.recordStartConnection()
    }
    
    internal func recordPaymentStatus(status: String) { AnalyticsService.recordPaymentStatus(status: status) }
    
    internal func getUserProperties() -> AnalyticsUserProperties {
        if let userProperties = self.UserPropertiesCache.getValue(forKey: "userproperties") {
            return userProperties
        } else {
            let package = Bundle.main.bundleIdentifier ?? "Unknown Bundle ID"
            
            var environment = ""
            switch BuildConfiguration.environment {
            case .debugSDKDev, .releaseSDKDev:
                environment = "dev"
            case .debugSDKProd, .releaseSDKProd:
                environment = "prod"
            }
            
            let theme = "system_light"
            let deviceModel = Device.current.description
            let iosVersion = Device.current.systemVersion?.description ?? "Unknown iOS version"
            
            let properties = AnalyticsUserProperties(package: package, environment: environment, theme: theme, iosVersion: iosVersion, iphoneModel: deviceModel)
            
            self.UserPropertiesCache.setValue(properties, forKey: "userproperties", storageOption: .memory)
            
            return properties
        }
    }
}

