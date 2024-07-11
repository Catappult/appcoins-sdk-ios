//
//  AnalyticsUserProperties.swift
//  
//
//  Created by Graciano Caldeira on 11/07/2024.
//

import Foundation

public struct AnalyticsUserProperties {
    
    let aptoideBundleID: String
    let environment: String
    let theme: String
    let iosVersion: String
    let iphoneModel: String
    
    init(aptoideBundleID: String, environment: String, theme: String, iosVersion: String, iphoneModel: String) {
        self.aptoideBundleID = aptoideBundleID
        self.environment = environment
        self.theme = theme
        self.iosVersion = iosVersion
        self.iphoneModel = iphoneModel
    }
    
    func toDict() -> [AnyHashable : Any] {
        return [
            "aptoide_package": aptoideBundleID,
            "environment": environment,
            "theme": theme,
            "ios_version": iosVersion,
            "iphone_model": iphoneModel
        ]
    }
}
