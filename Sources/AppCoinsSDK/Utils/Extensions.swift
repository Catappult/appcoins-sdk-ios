//
//  Extensions.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 12/05/2025.
//

import SwiftUI
import UIKit

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

extension UIColor {
    convenience init?(color: Color) {
        let uiView = UIHostingController(rootView: Rectangle().fill(color)).view
        let size = CGSize(width: 1, height: 1)

        uiView?.bounds = CGRect(origin: .zero, size: size)
        uiView?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { _ in
            uiView?.drawHierarchy(in: uiView!.bounds, afterScreenUpdates: true)
        }

        guard let pixelColor = image.cgImage?.dataProvider?.data,
              let ptr = CFDataGetBytePtr(pixelColor) else {
            return nil
        }

        let r = CGFloat(ptr[0]) / 255.0
        let g = CGFloat(ptr[1]) / 255.0
        let b = CGFloat(ptr[2]) / 255.0
        let a = CGFloat(ptr[3]) / 255.0

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
