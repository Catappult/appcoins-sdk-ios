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
            if let isDefault = SDKUseCases.shared.isDefault() {
                return isDefault
            } else {
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
            }
            #endif
        } else { return false }
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
                    BottomSheetViewModel.shared.handleWebViewDeeplink(deeplink: redirectURL.absoluteString)
                }
            } else {
                BottomSheetViewModel.shared.handleWebViewDeeplink(deeplink: redirectURL.absoluteString)
            }
            
            return URLComponents(string: redirectURL.absoluteString)?.scheme == "\(BuildConfiguration.packageName).iap"
        } else {
            return false
        }
    }
}
