//
//  AppCoinsSDK.swift
//
//
//  Created by aptoide on 21/09/2023.
//

import Foundation
@_implementationOnly import StoreKit
@_implementationOnly import IndicativeLibrary
@_implementationOnly import MarketplaceKit

public struct AppcSDK {
    
    /// Checks if the AppcSDK is available in the current environment.
    ///
    /// - For development mode (`BuildConfiguration.isDev == true`), the SDK is always available.
    /// - For iOS 17.4 or later, it checks the current storefront using the `AppDistributor` API.
    ///   - If the storefront is any marketplace but the Aptoide marketplace (`"com.aptoide.ios.store"`), the SDK is considered unavailable.
    ///   - For any other storefront, the SDK is considered available.
    /// - For iOS versions below 17.4, the SDK is unavailable.
    ///
    /// - Returns: `true` if the SDK is available, `false` otherwise.
    ///
    /// Example usage:
    /// ```swift
    /// let isAvailable = await AppcSDK.isAvailable()
    /// if isAvailable {
    ///     // Proceed with SDK functionality
    /// } else {
    ///     // Handle SDK unavailability
    /// }
    /// ```
    static public func isAvailable() async -> Bool {
        if #available(iOS 17.4, *) {
            #if targetEnvironment(simulator)
                return true
            #else
                do {
                    let storefront = try await AppDistributor.current
                    switch storefront {
                    case .appStore:
                        return false
                    case .marketplace(let marketplace):
                        return marketplace == "com.aptoide.ios.store"
                    default:
                        return true
                    }
                } catch {
                    return false
                }
            #endif
        } else { return false }
    }

    /// Handles the redirect URL and routes it to the appropriate handler. Should be called at all entrypoints of the application.
    ///
    /// - It initializes internal processes of the AppCoins SDK: `AppcSDKInternal.initialize()`.
    /// - Deals with two types of redirectURL's:
    ///   - DeepLinks coming from the Appcoins wallet
    ///   - DeepLinks coming from Adyen payment redirects
    ///
    /// - Parameters:
    ///   - redirectURL: The URL received for redirection, which is from a DeepLink into the application.
    /// - Returns: `true` if the URL was handled successfully, `false` otherwise.
    ///
    /// Example usage:
    /// ```swift
    /// if AppcSDK.handle(redirectURL: URLContexts.first?.url) { return }
    /// ```
    static public func handle(redirectURL: URL?) -> Bool {
        
        AppcSDKInternal.initialize()
        
        if let redirectURL = redirectURL {
            if let host = redirectURL.host, host == "wallet.appcoins.io" {
                let pathRoot = redirectURL.pathComponents[1]
                if pathRoot == "sync" {
                    SyncWalletViewModel.shared.importWalletReturn(redirectURL: redirectURL)
                    return true
                } else if pathRoot == "auth" {
                    if let code = URLComponents(url: redirectURL, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "code" })?.value {
                        AuthViewModel.shared.loginWithMagicLink(code: code)
                        return true
                    }
                }
            } else {
                return AdyenController.shared.handleRedirectURL(redirectURL: redirectURL)
            }
        }
        return false
    }
    
}
