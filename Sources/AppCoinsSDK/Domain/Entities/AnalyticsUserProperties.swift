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
    internal let country: String
    internal let language: String
    internal let guestUID: String
    internal let OEMID: String
    
    internal init(package: String, environment: String, theme: String, iosVersion: String, iphoneModel: String, country: String, language: String, guestUID: String, OEMID: String) {
        self.package = package
        self.environment = environment
        self.theme = theme
        self.iosVersion = iosVersion
        self.iphoneModel = iphoneModel
        self.country = country
        self.language = language
        self.guestUID = guestUID
        self.OEMID = OEMID
    }
    
    internal func toDict() -> [AnyHashable : Any] {
        return [
            "application_package": package,
            "environment": environment,
            "theme": theme,
            "ios_version": iosVersion,
            "iphone_model": iphoneModel,
            "country": country,
            "language": language,
            "guest_uid": guestUID,
            "oemid": OEMID
        ]
    }
}
