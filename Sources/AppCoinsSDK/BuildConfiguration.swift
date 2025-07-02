//
//  BuildConfiguration.swift
//
//
//  Created by aptoide on 02/03/2023.
//

import Foundation
import SwiftUI

internal class BuildConfiguration {
    static internal let shared = BuildConfiguration()
    
    static internal var isDev: Bool {
        return Bundle.main.bundleIdentifier == "com.appcoins.trivialdrivesample.test"
    }
    
    static internal var environment: SDKEnvironment {
        if BuildConfiguration.isDev { return .releaseSDKDev }
        else { return .releaseSDKProd }
    }
    
    static internal var packageName : String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    static internal var appName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }
    
    static internal var productServiceURL: String {
        switch environment {
        case .debugSDKDev, .releaseSDKDev:
            return "https://api.dev.catappult.io/productv2/8.20240812"
        case .debugSDKProd, .releaseSDKProd:
            return "https://api.catappult.io/productv2/8.20240812"
        }
    }
    
    static internal var APPCServiceURL: String {
        switch environment {
        case .debugSDKDev, .releaseSDKDev:
            return "https://apichain.dev.catappult.io/appc"
        case .debugSDKProd, .releaseSDKProd:
            return "https://apichain.catappult.io/appc"
        }
    }
    
    static internal var mmpServiceBaseURL: String {
        switch environment {
        case .debugSDKDev, .releaseSDKDev:
            return "https://aptoide-mmp-v3-dev.aptoide.com"
        case .debugSDKProd, .releaseSDKProd:
            return "https://aptoide-mmp.aptoide.com"
        }
    }
    
    static internal var transactionServiceURL: String {
        switch environment {
        case .debugSDKDev, .releaseSDKDev:
            return "https://apichain.dev.catappult.io/transaction"
        case .debugSDKProd, .releaseSDKProd:
            return "https://apichain.catappult.io/transaction"
        }
    }
    
    static internal var webCheckoutURL: String {
        switch environment {
        case .debugSDKDev, .releaseSDKDev:
            return "https://wallet.dev.appcoins.io/iap/sdk"
        case .debugSDKProd, .releaseSDKProd:
            return "https://developers.catappult.io/iap/sdk"
        }
    }
    
    static internal var brokerServiceURL: String {
        switch environment {
        case .debugSDKDev, .releaseSDKDev:
            return "https://api.dev.catappult.io/broker/8.20240812"
        case .debugSDKProd, .releaseSDKProd:
            return "https://api.catappult.io/broker/8.20240812"
        }
    }
    
    static internal var googleAnalyticsMeasurementServiceURL: String = "https://www.google-analytics.com"
    
    static internal var aptoideOEMID = "a37f1d7a4599d0ba60f23f9ff7b9ce95"
    
    static internal var userUID =  UIDevice.current.identifierForVendor!.uuidString
    
    // WARNING: Changing this variable definition might break CI/CD
    static internal var sdkShortVersion: String = "2.1.0"
    
    // WARNING: Changing this variable definition might break CI/CD
    static internal var sdkBuildNumber: Int = 30
}

internal enum SDKEnvironment: String {
    case debugSDKDev = "Debug AppCoins SDK Dev"
    case releaseSDKDev = "Release AppCoins SDK Dev"
    
    case debugSDKProd = "Debug AppCoins SDK Prod"
    case releaseSDKProd = "Release AppCoins SDK Prod"
}
