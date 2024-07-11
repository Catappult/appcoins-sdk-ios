//
//  AnalyticsRepository.swift
//
//
//  Created by Graciano Caldeira on 09/07/2024.
//

import Foundation
import DeviceKit

internal class AnalyticsRepository: AnalyticsRepositoryProtocol {
    
    private let AnalyticsService: AnalyticsService = IndicativeAnalyticsClient()
    private var userProperties: AnalyticsUserProperties? = nil
    
    internal func initialize() { AnalyticsService.initialize(userProperties: self.getUserProperties()) }
    
    internal func recordPurchaseIntent(paymentMethod: String) {
        AnalyticsService.recordPurchaseIntent(paymentMethod: paymentMethod)
    }
    
    internal func recordStartConnection() {
        AnalyticsService.recordStartConnection()
    }
    
    internal func getUserProperties() -> AnalyticsUserProperties {
        if let userProp = self.userProperties {
            return userProp
        } else {
            let aptoideBundleID = Bundle.main.bundleIdentifier ?? "Unknown Bundle ID"
            
            var environment = ""
            switch BuildConfiguration.environment {
            case .debugSDKDev, .releaseSDKDev:
                environment = "dev"
            case .debugSDKProd, .releaseSDKProd:
                environment = "prod"
            }
            
            let theme = "system_light"
            let aptoideShortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown Version"
            let deviceModel = Device.current.description
            let iosVersion = Device.current.systemVersion?.description ?? "Unknown iOS version"
            
            return AnalyticsUserProperties(aptoideBundleID: aptoideBundleID, environment: environment, theme: theme, versionCode: aptoideShortVersion, iosVersion: iosVersion, iphoneModel: deviceModel)
        }
    }
}
