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
    
    static internal var appcDomain: String {
        switch environment {
            case .debugSDKDev, .releaseSDKDev:
                return "com.appcoins.wallet.dev"
            case .debugSDKProd, .releaseSDKProd:
                return "com.appcoins.wallet"
        }
    }
    
    static internal var productServiceURL: String {
        switch environment {
            case .debugSDKDev, .releaseSDKDev:
                return "https://api.dev.catappult.io/productv2/8.20240812"
            case .debugSDKProd, .releaseSDKProd:
                return "https://api.catappult.io/productv2/8.20240812"
        }
    }
    
    static internal var gamificationServiceURL: String {
        switch environment {
            case .debugSDKDev, .releaseSDKDev:
                return "https://apichain.dev.catappult.io/gamification"
            case .debugSDKProd, .releaseSDKProd:
                return "https://apichain.catappult.io/gamification"
        }
    }
    
    static internal var aptoideIosServiceURL: String {
        switch environment {
            case .debugSDKDev, .releaseSDKDev:
                return "https://api.dev.aptoide.com/aptoide-ios"
            case .debugSDKProd, .releaseSDKProd:
                return "https://api.aptoide.com/aptoide-ios"
        }
    }
    
    static internal var billingServiceURL: String {
        switch environment {
            case .debugSDKDev, .releaseSDKDev:
                return "https://api.dev.catappult.io/broker/8.20240812"
            case .debugSDKProd, .releaseSDKProd:
                return "https://api.catappult.io/broker/8.20240812"
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
            return "https://aptoide-mmp.dev.aptoide.com"
        case .debugSDKProd, .releaseSDKProd:
            return "https://aptoide-mmp.aptoide.com"
        }
    }
    
    static internal var aptoideWebservicesBaseURL: String {
        switch environment {
        case .debugSDKDev, .releaseSDKDev:
            return "https://webservices-devel.aptoide.com/api/7"
        case .debugSDKProd, .releaseSDKProd:
            return "https://webservices.aptoide.com/api/7"
        }
    }
    
    static internal var aptoideOEMID = "a37f1d7a4599d0ba60f23f9ff7b9ce95"
    
    static internal var userUID =  UIDevice.current.identifierForVendor!.uuidString
    
    static internal var sdkShortVersion: String = "1.6.1"
}

internal enum SDKEnvironment: String {
    case debugSDKDev = "Debug AppCoins SDK Dev"
    case releaseSDKDev = "Release AppCoins SDK Dev"

    case debugSDKProd = "Debug AppCoins SDK Prod"
    case releaseSDKProd = "Release AppCoins SDK Prod"
}

