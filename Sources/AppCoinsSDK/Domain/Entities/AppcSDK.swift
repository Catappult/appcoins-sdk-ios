//
//  AppCoinsSDK.swift
//
//
//  Created by aptoide on 21/09/2023.
//

import Foundation
@_implementationOnly import StoreKit
@_implementationOnly import MarketplaceKit

public struct AppcSDK {
    
    /// Checks whether the AppcSDK should be enabled in the current environment.
    ///
    /// - In the Simulator (`targetEnvironment(simulator)`), always returns `true`.
    /// - If `SDKUseCases.shared.isDefault()` returns a non‐nil override, returns that value.
    /// - Otherwise, enables external purchases if **either**:
    ///   1. **United States storefront**
    ///      - Returns `true` if user is in the United States.
    ///   2. **European Union marketplace**
    ///      - On iOS 17.4+ uses `AppDistributor.current`:
    ///         - returns `false` for `.appStore`
    ///         - returns `true` only if `marketplace == "com.aptoide.ios.store"`
    ///         - returns `true` for any other non-App Store case
    ///      - On older OS returns `false`.
    ///
    /// - Returns: `true` if the SDK is available, `false` otherwise.
    static public func isAvailable() async -> Bool {
        #if targetEnvironment(simulator)
        return true
        #endif
        
        if let isDefault = SDKUseCases.shared.isDefault() {
            return isDefault
        }
        
        let usAllowed = await isAvailableInUS()
        let euAllowed = await isAvailableInEU()
        return usAllowed || euAllowed
    }

    static internal func isAvailableInUS() async -> Bool {
        let localeIsUS = (Locale.current.regionCode == "US")
        
        // On older OS versions just return the locale
        guard #available(iOS 15.0, *) else {
            return localeIsUS
        }
        
        do {
            let storefront = try await StoreKit.Storefront.current
            print(storefront)
            return (storefront?.countryCode == "USA")
        } catch {
            // If the Storefront lookup fails, fall back to the locale
            return localeIsUS
        }
    }

    static internal func isAvailableInEU() async -> Bool {
        do {
            guard #available(iOS 17.4, *) else {
                return false
            }
            
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
    }
    
    /// Handles the redirect URL and routes it to the appropriate handler. Should be called at all entrypoints of the application.
    ///
    /// - It initializes internal processes of the AppCoins SDK: `AppcSDKInternal.initialize()`.
    /// - Deals with two types of redirectURL's:
    ///   - DeepLinks coming from the Appcoins wallet
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
                let queryItems = URLComponents(string: redirectURL.absoluteString)?.queryItems
                
                switch redirectURL.pathComponents[1] {
                case "default":
                    if let rawValue = queryItems?.first(where: { $0.name == "value" })?.value {
                        let value = rawValue.lowercased() == "true" ? true : false
                        SDKUseCases.shared.setSDKDefault(value: value)
                    }
                case "purchase":
                    if let sku = queryItems?.first(where: { $0.name == "product" })?.value {
                        let payload = queryItems?.first(where: { $0.name == "payload" })?.value
                        let orderID = queryItems?.first(where: { $0.name == "orderID" })?.value
                        
                        Task {
                            guard let product = await try? Product.products(for: [sku]).first else { return }
                            
                            let result = orderID != nil
                            ? await product.indirectPurchase(payload: payload, orderID: orderID!)
                            : await product.indirectPurchase(payload: payload)
                            
                            if case let .success(verificationResult) = result {
                                Purchase.send(verificationResult)
                            }
                        }
                    }
                default:
                    PurchaseViewModel.shared.handleWebViewDeeplink(deeplink: redirectURL.absoluteString)
                }
            } else {
                PurchaseViewModel.shared.handleWebViewDeeplink(deeplink: redirectURL.absoluteString)
            }
            
            return URLComponents(string: redirectURL.absoluteString)?.scheme == "\(BuildConfiguration.packageName).iap"
        } else {
            return false
        }
    }
}
