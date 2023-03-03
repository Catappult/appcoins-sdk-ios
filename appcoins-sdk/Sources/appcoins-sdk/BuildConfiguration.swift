//
//  BuildConfiguration.swift
//  appcoins-sdk
//
//  Created by aptoide on 02/03/2023.
//

import Foundation
import SwiftUI

class BuildConfiguration {
    static let shared = BuildConfiguration()
    
    // dev for now
    static var baseURL: String {
        return "https://apichain.dev.catappult.io"
    }
    
    static var packageName : String {
        return Bundle.main.bundleIdentifier ?? ""
    }
}

