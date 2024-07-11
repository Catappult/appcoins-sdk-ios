//
//  AnalyticsRepository.swift
//  
//
//  Created by Graciano Caldeira on 09/07/2024.
//

import Foundation
import DeviceKit

class AnalyticsRepository: AnalyticsRepositoryProtocol {
    
    private let AnalyticsService: AnalyticsService = IndicativeAnalyticsClient()
    private var userProperties: AnalyticsUserProperties? = nil
    
    func initialize() { AnalyticsService.initialize(userProperties: self.getUserProperties()) }
    func recordPurchaseIntent() {
        AnalyticsService.recordPurchaseIntent()
    }
    func recordUnexpectedFailure() {}
    
    func getUserProperties() -> AnalyticsUserProperties {
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
