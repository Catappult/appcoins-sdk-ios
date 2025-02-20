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

internal extension UIApplication {
    func dismissKeyboard() {
        self.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

internal extension String {
    func stripTrailingSpace() -> String {
        guard let lastCharacter = self.last, lastCharacter == " " else {
            return self // Return the original string if there's no trailing space
        }
        return String(self.dropLast()) // Remove only the last character (trailing space)
    }
}
