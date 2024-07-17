//
//  AnalyticsUserProperties.swift
//  
//
//  Created by Graciano Caldeira on 11/07/2024.
//

import Foundation

public struct AnalyticsUserProperties: Codable {
    
    let package: String
    let environment: String
    let theme: String
    let iosVersion: String
    let iphoneModel: String
    
    init(package: String, environment: String, theme: String, iosVersion: String, iphoneModel: String) {
        self.package = package
        self.environment = environment
        self.theme = theme
        self.iosVersion = iosVersion
        self.iphoneModel = iphoneModel
    }
    
    func toDict() -> [AnyHashable : Any] {
        return [
            "application_package": package,
            "environment": environment,
            "theme": theme,
            "ios_version": iosVersion,
            "iphone_model": iphoneModel
        ]
    }
}
