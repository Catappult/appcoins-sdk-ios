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
    
    private init() {}
    
    public static var configuration = Configuration()
    
    public struct Configuration {
        var isAppCoinsDevToolsEnabled: Bool
        var storefront: AppcStorefront?
        
        init() {
            self.isAppCoinsDevToolsEnabled = Bundle.main.isAppCoinsDevToolsEnabled
            
            if self.isAppCoinsDevToolsEnabled {
                Utils.log("AppCoinsDevTools are Enabled")
                
                var locale: AppcStorefront.Locale?
                var marketplace: AppcStorefront.Marketplace?

                if let rawLocale = SDKUseCases.shared.getDefaultStorefrontLocale() {
                    locale = AppcStorefront.Locale.fromRaw(raw: rawLocale)
                }
                if let rawMarketplace = SDKUseCases.shared.getDefaultStorefrontMarketplace() {
                    marketplace = AppcStorefront.Marketplace.fromRaw(raw: rawMarketplace)
                }
                
                self.storefront = AppcStorefront(locale: locale, marketplace: marketplace)
            } else {
                Utils.log("AppCoinsDevTools are not Enabled")
                self.storefront = nil
            }
        }
    }
    
    /// Configures the AppcSDK default storefront overrides for locale and marketplace.
    ///
    /// - This method only takes effect when `AppCoinsDevTools` are enabled:
    ///   - If `locale` is provided, sets the SDK default storefront locale to `locale`.
    ///   - If `marketplace` is provided, sets the SDK default storefront marketplace to `marketplace`.
    ///   - Updates `AppcSDK.configuration.storefront` with the provided `locale` and `marketplace`.
    ///
    /// - Parameters:
    ///   - locale: Optional `AppcStorefront.Locale` to override the default locale.
    ///   - marketplace: Optional `AppcStorefront.Marketplace` to override the default marketplace.
    static public func configure(locale: AppcStorefront.Locale? = nil, marketplace: AppcStorefront.Marketplace? = nil) {
        if AppcSDK.configuration.isAppCoinsDevToolsEnabled {
            var newLocale: AppcStorefront.Locale? = AppcSDK.configuration.storefront?.locale
            var newMarketplace: AppcStorefront.Marketplace? = AppcSDK.configuration.storefront?.marketplace
            
            if let locale = locale {
                SDKUseCases.shared.setSDKDefaultStorefrontLocale(locale: locale.code)
                newLocale = locale
            }
            
            if let marketplace = marketplace {
                SDKUseCases.shared.setSDKDefaultStorefrontMarketplace(marketplace: marketplace.rawValue)
                newMarketplace = marketplace
            }
            
            AppcSDK.configuration.storefront = AppcStorefront(locale: newLocale, marketplace: newMarketplace)
        }
    }
    
    
    /// Checks whether the AppcSDK should be enabled in the current environment.
    ///
    /// - If `BuildConfiguration.isDev` always returns `true`.
    /// - Checks whether the default locale is valid for EU storefronts.
    ///    - On iOS 17.4+ uses `AppDistributor.current`:
    ///       - returns `false` for `.appStore`
    ///       - returns `true` only if `marketplace == "com.aptoide.ios.store"`
    ///       - returns `true` for any other non-App Store case
    ///    - On older OS returns `false`.
    ///
    /// - Returns: `true` if the SDK is available, `false` otherwise.
    static public func isAvailable() async -> Bool {
        if BuildConfiguration.isDev {
            return true
        }
        
        if AppcSDK.configuration.isAppCoinsDevToolsEnabled, let defaultLocale = AppcSDK.configuration.storefront?.locale {
            guard AppcStorefront.Locale.EU.contains(defaultLocale) else {
                return false
            }
            
            if let defaultMarketplace = AppcSDK.configuration.storefront?.marketplace {
                switch defaultMarketplace {
                case .aptoide:
                    return true
                case .apple:
                    return false
                }
            }
        }
        
        do {
            guard #available(iOS 17.4, *) else {
                return false
            }
            
            #if targetEnvironment(simulator)
                Utils.log("Can't validate App Distributor on Simulator. To test different billings (Apple vs. Aptoide) use an actual device or enable AppCoinsDevTools.")
                return true
            #else
                let storefront = try await AppDistributor.current
                switch storefront {
                case .appStore:
                    return false
                default:
                    return true
                }
            #endif
        } catch {
            return false
        }
    }
    
    /// Handles the redirect URL and routes it to the appropriate handler. Should be called at all entrypoints of the application.
    ///
    /// - It initializes internal processes of the AppCoins SDK: `AppcSDKInternal.initialize()`.
    /// - Deals with two types of redirectURL's:
    ///   - DeepLinks coming from the Appcoins wallet
    ///   - Handles deep links coming from the WebCheckout WebView
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
                    if redirectURL.pathComponents.count > 2 {
                        if redirectURL.pathComponents[2] == "storefront" {
                            var locale: AppcStorefront.Locale?
                            var marketplace: AppcStorefront.Marketplace?
                            
                            if let rawLocale = queryItems?.first(where: { $0.name == "locale" })?.value {
                                locale = AppcStorefront.Locale.fromRaw(raw: rawLocale)
                                if locale == nil { Utils.log("Invalid Storefront Locale: \(rawLocale)") }
                            }
                            
                            if let rawMarketplace = queryItems?.first(where: { $0.name == "marketplace" })?.value {
                                marketplace = AppcStorefront.Marketplace.fromRaw(raw: rawMarketplace)
                                if marketplace == nil { Utils.log("Invalid Storefront Marketplace: \(rawMarketplace)") }
                            }
                            
                            AppcSDK.configure(locale: locale, marketplace: marketplace)
                        }
                    } else {
                        if let rawValue = queryItems?.first(where: { $0.name == "value" })?.value {
                            let value = rawValue.lowercased() == "true" ? true : false
                            SDKUseCases.shared.setSDKDefault(value: value)
                        }
                    }
                case "purchase":
                    if let sku = queryItems?.first(where: { $0.name == "product" })?.value {
                        let discountPolicy = queryItems?.first(where: { $0.name == "discount_policy" })?.value.flatMap { DiscountPolicy(rawValue: $0) }
                        let oemID = queryItems?.first(where: { $0.name == "oemid" })?.value
                        
                        Task {
                            ProductUseCases.shared.getProduct(domain: BuildConfiguration.packageName, product: sku, discountPolicy: discountPolicy) { result in
                                
                                if case .success(let product) = result {
                                    PurchaseIntentManager.shared.set(intent: PurchaseIntent(product: product, discountPolicy: discountPolicy, oemID: oemID))
                                } else {
                                    Utils.log("Indirect purchase failed: product not found for SKU '\(sku)'")
                                }
                            }
                        }
                    }
                case "checkout":
                    if redirectURL.pathComponents.count > 2 {
                        switch redirectURL.pathComponents[2] {
                        case "success":
                            PurchaseViewModel.shared.handleCheckoutSuccessDeeplink(deeplink: redirectURL)
                        case "failure":
                            PurchaseViewModel.shared.handleCheckoutFailureDeeplink(deeplink: redirectURL)
                        default:
                            break
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

/// Reads the `AppCoinsDevToolsEnabled` key (as a string) and returns its Bool value.
public extension Bundle {
    var isAppCoinsDevToolsEnabled: Bool {
        guard let raw = infoDictionary?["AppCoinsDevToolsEnabled"] as? String else {
            return false
        }
        return (raw as NSString).boolValue // NSString.boolValue handles "YES"/"yes"/"1"/"TRUE" etc.
    }
}
