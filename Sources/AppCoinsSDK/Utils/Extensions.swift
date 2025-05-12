//
//  Extensions.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 12/05/2025.
//

import SwiftUI

// For some reason this solves the issue 'module' is inaccessible due to 'internal' protection level
internal extension Bundle {
    static internal let APPCModule: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        // Fallback for non-Swift Package Manager (e.g., Framework)
        let bundleName = "AppCoinsSDK"
        let candidates = [
            Bundle.main.resourceURL,
            Bundle(for: BuildConfiguration.self).resourceURL,
            Bundle.main.bundleURL
        ]
        
        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent("\(bundleName).bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        return Bundle(for: BuildConfiguration.self)
        #endif
    }()
}
