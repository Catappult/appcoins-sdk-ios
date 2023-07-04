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
    
    // For now we only work on dev environment
    static var environment: SDKEnvironment = .debugSDKDev
    
    
    static var packageName : String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    static var appcDomain: String {
        switch environment {
            case .debugSDKDev, .releaseSDKDev:
                return "com.appcoins.wallet.dev"
            case .debugSDKProd, .releaseSDKProd:
                return "com.appcoins.wallet"
        }
    }
    
    static var productServiceURL: String {
        switch environment {
            case .debugSDKDev, .releaseSDKDev:
                return "https://api.dev.catappult.io/productv2/8.20200701"
            case .debugSDKProd, .releaseSDKProd:
                return "https://api.catappult.io/productv2/8.20200701"
        }
    }
    
    static var gamificationServiceURL: String {
        switch environment {
            case .debugSDKDev, .releaseSDKDev:
                return "https://apichain.dev.catappult.io/gamification"
            case .debugSDKProd, .releaseSDKProd:
                return "https://apichain.catappult.io/gamification"
        }
    }
    
    static var aptoideIosServiceURL: String {
        switch environment {
            case .debugSDKDev, .releaseSDKDev:
                return "https://api.aptoide.com/aptoide-ios/8.20220701"
            case .debugSDKProd, .releaseSDKProd:
                return "https://api.aptoide.com/aptoide-ios/8.20220701"
        }
    }
    
    static var aptoideServiceURL: String {
        switch environment {
            case .debugSDKDev, .releaseSDKDev:
                return "https://ws75-devel.aptoide.com/api/7"
            case .debugSDKProd, .releaseSDKProd:
                return "https://ws75-devel.aptoide.com/api/7"
        }
    }
    
    static var billingServiceURL: String {
        switch environment {
            case .debugSDKDev, .releaseSDKDev:
                return "https://api.dev.catappult.io/broker/8.20230522"
            case .debugSDKProd, .releaseSDKProd:
                return "https://api.catappult.io/broker/8.20230522"
        }
    }
    
    static var transactionServiceURL: String {
        switch environment {
            case .debugSDKDev, .releaseSDKDev:
                return "https://apichain.dev.catappult.io/transaction"
            case .debugSDKProd, .releaseSDKProd:
                return "https://apichain.catappult.io/transaction"
        }
    }
    
    static var APPCServiceURL: String {
        switch environment {
            case .debugSDKDev, .releaseSDKDev:
                return "https://apichain.dev.catappult.io/appc"
            case .debugSDKProd, .releaseSDKProd:
                return "https://apichain.catappult.io/appc"
        }
    }
    
    static var userUID =  UIDevice.current.identifierForVendor!.uuidString
}

enum SDKEnvironment: String {
    case debugSDKDev = "Debug AppCoins SDK Dev"
    case releaseSDKDev = "Release AppCoins SDK Dev"

    case debugSDKProd = "Debug AppCoins SDK Prod"
    case releaseSDKProd = "Release AppCoins SDK Prod"
}

