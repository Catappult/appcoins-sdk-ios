//
//  AppCoinsSDK.swift
//
//
//  Created by aptoide on 21/09/2023.
//

import Foundation
import StoreKit
import IndicativeLibrary
import MarketplaceKit

public struct AppcSDK {
    
    static public func isAvailable() async -> Bool {
        if #available(iOS 17.4, *) {
            do {
                let storefront = try await AppDistributor.current
                switch storefront {
                case .marketplace(let marketplace):
                    return marketplace == "com.aptoide.ios.store"
                default:
                    return false
                }
            } catch {
                return false
            }
        } else { return false }
    }

    static public func handle(redirectURL: URL?) -> Bool {
        
        AnalyticsUseCases.shared.initialize()
        
        if let redirectURL = redirectURL {
            if let host = redirectURL.host, host == "wallet.appcoins.io" {
                let pathRoot = redirectURL.pathComponents[1]
                if pathRoot == "sync" {
                    SyncWalletViewModel.shared.importWalletReturn(redirectURL: redirectURL)
                    return true
                }
            } else {
                return AdyenController.shared.handleRedirectURL(redirectURL: redirectURL)
            }
        }
        return false
    }
    
}
