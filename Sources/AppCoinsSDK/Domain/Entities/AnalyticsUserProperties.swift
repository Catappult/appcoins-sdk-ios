//
//  AnalyticsUserProperties.swift
//  
//
//  Created by Graciano Caldeira on 11/07/2024.
//

import Foundation

internal struct AnalyticsUserProperties: Codable {
    
    internal let package: String
    internal let environment: String
    internal let theme: String
    internal let iosVersion: String
    internal let iphoneModel: String
    
    internal init(package: String, environment: String, theme: String, iosVersion: String, iphoneModel: String) {
        self.package = package
        self.environment = environment
        self.theme = theme
        self.iosVersion = iosVersion
        self.iphoneModel = iphoneModel
    }
    
    internal func toDict() -> [AnyHashable : Any] {
        return [
            "application_package": package,
            "environment": environment,
            "theme": theme,
            "ios_version": iosVersion,
            "iphone_model": iphoneModel
        ]
    }
}
