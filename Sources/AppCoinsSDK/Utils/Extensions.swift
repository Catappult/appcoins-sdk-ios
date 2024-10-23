//
//  Extensions.swift
//  
//
//  Created by aptoide on 21/09/2023.
//

import SwiftUI

internal extension UIView {
    internal func findAndResignFirstResponder() {
        if isFirstResponder {
            resignFirstResponder()
        } else {
            for subview in subviews {
                subview.findAndResignFirstResponder()
            }
        }
    }
}

// For some reason this solves the issue 'module' is inaccessible due to 'internal' protection level
public extension Bundle {
    static let module: Bundle = {
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
    }()
}
