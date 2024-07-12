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
    private let dev = "9dzeuP8lxyesMDl4sr5YICM9GBGl2MpflHjO/3NVEYoOBUhS6r2lPIUS6QWVcgzYs2sM5bUVMg3JRmDDJKRECg=="
    private let prod = "XSD6BIfei99TpkuCIdS5ZrcqUk/3sYOqJZ4MwtOpzkwrEfBRIRb/QtLwP58atuETwAP53lnBCbrWQwzxSMlMJQ=="
    
    internal func initialize() {
        
        var environment = ""
        switch BuildConfiguration.environment {
        case .debugSDKDev, .releaseSDKDev:
            environment = self.dev
        case .debugSDKProd, .releaseSDKProd:
            environment = self.prod
        }
        AnalyticsService.initialize(userProperties: self.getUserProperties(), environment: environment)
    }
    
    internal func recordPurchaseIntent(paymentMethod: String) {
        AnalyticsService.recordPurchaseIntent(paymentMethod: paymentMethod)
    }
    
    internal func recordStartConnection() {
        AnalyticsService.recordStartConnection()
    }
    
    internal func recordPaymentStatus(status: String) { AnalyticsService.recordPaymentStatus(status: status) }
    
    internal func getUserProperties() -> AnalyticsUserProperties {
        if let userProp = self.userProperties {
            return userProp
        } else {
            let applicationBundleID = Bundle.main.bundleIdentifier ?? "Unknown Bundle ID"
            
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
            
            let prop = AnalyticsUserProperties(applicationBundleID: applicationBundleID, environment: environment, theme: theme, iosVersion: iosVersion, iphoneModel: deviceModel)
            self.userProperties = prop
            
            return prop
        }
    }
}
