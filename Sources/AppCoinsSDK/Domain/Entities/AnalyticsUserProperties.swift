//
//  AnalyticsUserProperties.swift
//  
//
//  Created by Graciano Caldeira on 11/07/2024.
//

import Foundation

public struct AnalyticsUserProperties: Codable {
    
    let applicationBundleID: String
    let environment: String
    let theme: String
    let iosVersion: String
    let iphoneModel: String
    
    init(applicationBundleID: String, environment: String, theme: String, iosVersion: String, iphoneModel: String) {
        self.applicationBundleID = applicationBundleID
        self.environment = environment
        self.theme = theme
        self.iosVersion = iosVersion
        self.iphoneModel = iphoneModel
    }
    
    func toDict() -> [AnyHashable : Any] {
        return [
            "application_package": applicationBundleID,
            "environment": environment,
            "theme": theme,
            "ios_version": iosVersion,
            "iphone_model": iphoneModel
        ]
    }
}
