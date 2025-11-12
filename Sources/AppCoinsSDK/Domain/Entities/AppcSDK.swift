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
            Utils.log(
                "Configuration.init() at AppcSDK.swift",
                category: "Lifecycle",
                level: .info
            )
            
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
        Utils.log(
            "AppcSDK.configure(locale: \(locale), marketplace: \(marketplace)) at AppcSDK.swift",
            category: "Lifecycle",
            level: .info
        )
        
        if AppcSDK.configuration.isAppCoinsDevToolsEnabled {
            var newLocale: AppcStorefront.Locale? = AppcSDK.configuration.storefront?.locale
            var newMarketplace: AppcStorefront.Marketplace? = AppcSDK.configuration.storefront?.marketplace
            
            if let locale = locale {
                SDKUseCases.shared.setSDKDefaultStorefrontLocale(locale: locale.code)
                newLocale = locale
                Utils.log("Storefront locale set to: \(newLocale) at AppcSDK.swift:configure")
            }
            
            if let marketplace = marketplace {
                SDKUseCases.shared.setSDKDefaultStorefrontMarketplace(marketplace: marketplace.rawValue)
                newMarketplace = marketplace
                Utils.log("Storefront marketplace set to: \(newMarketplace) at AppcSDK.swift:configure")
            }
            
            Utils.log("AppCoinsDevTools are enabled. Updating configuration at AppcSDK.swift:configure")
            AppcSDK.configuration.storefront = AppcStorefront(locale: newLocale, marketplace: newMarketplace)
        } else {
            Utils.log("AppCoinsDevTools are not enabled. Skipping configuration at AppcSDK.swift:configure")
        }
    }
    
    
    /// Checks whether the AppcSDK should be enabled in the current environment.
    ///
    /// - If `BuildConfiguration.isDev` always returns `true`.
    /// - Checks whether the default locale is valid for EU storefronts.
    ///    - On iOS 17.4+ uses `AppDistributor.current`:
    ///       - returns `false` for `.appStore
    ///       - returns `true` for any other non-App Store case
    ///    - On older OS returns `false`.
    ///
    /// - Returns: `true` if the SDK is available, `false` otherwise.
    static public func isAvailable() async -> Bool {
        Utils.log(
            "AppcSDK.isAvailable() at AppcSDK.swift",
            category: "Lifecycle",
            level: .info
        )
        
        if BuildConfiguration.isDev {
            Utils.log("AppcSDK is available in dev mode at AppcSDK.swift:isAvailable")
            return true
        }
        
        if AppcSDK.configuration.isAppCoinsDevToolsEnabled, let defaultLocale = AppcSDK.configuration.storefront?.locale {
            guard AppcStorefront.Locale.EU.contains(defaultLocale) else {
                Utils.log("AppCoinsDevTools is enabled: non‑EU storefront detected. " +
                          "AppcSDK unavailable at AppcSDK.swift:isAvailable")
                return false
            }
            
            if let defaultMarketplace = AppcSDK.configuration.storefront?.marketplace {
                switch defaultMarketplace {
                case .aptoide:
                    Utils.log("AppCoinsDevTools is enabled: Aptoide storefront detected. " +
                              "AppcSDK available at AppcSDK.swift:isAvailable")
                    return true
                case .apple:
                    Utils.log("AppCoinsDevTools is enabled: Apple App Store storefront detected. " +
                              "AppcSDK unavailable at AppcSDK.swift:isAvailable")
                    return false
                }
            }
        }
        
        do {
            guard #available(iOS 17.4, *) else {
                Utils.log("AppcSDK isn't available for iOS versions below iOS 17.4 at AppcSDK.swift:isAvailable")
                return false
            }
            
            #if targetEnvironment(simulator)
                Utils.log("Can't validate App Distributor on Simulator. To test different billings " +
                          "(Apple vs. Aptoide) use an actual device or enable AppCoinsDevTools.")
                return true
            #else
                let storefront = try await AppDistributor.current
                switch storefront {
                case .appStore:
                    Utils.log("AppcSDK isn't available for storefront: \(storefront) at AppcSDK.swift:isAvailable")
                    return false
                default:
                    Utils.log("AppcSDK available for storefront: \(storefront) at AppcSDK.swift:isAvailable")
                    return true
                }
            #endif
        } catch {
            Utils.log(
                "AppcSDK isn't available. Failed to get storefront with error: " +
                "\(error.localizedDescription) at AppcSDK.swift:isAvailable",
                level: .error
            )
            return false
        }
    }
    
    /// Handles the redirect URL and routes it to the appropriate handler. Should be called at all entrypoints of the application.
    ///
    /// - It initializes internal processes of the AppCoins SDK: `AppcSDKInternal.initialize()`.
    /// - Deals with two types of redirectURL's:
    ///   - DeepLinks related to AppCoins SDK
    ///     Supported URL patterns:
    ///         - **wallet.appcoins.io/default**
    ///             - `/default/storefront`: sets the SDK default storefront locale and marketplace using query parameters:
    ///                 - `locale`: The storefront locale (e.g., `"pt-PT"`).
    ///                 - `marketplace`: The storefront marketplace (e.g., `"com.aptoide.ios.store"`).
    ///             - `/default?value=true|false`: enables or disables the SDK default feature flag.
    ///         - **wallet.appcoins.io/purchase**
    ///             - Triggers an indirect purchase by fetching product data and preparing a `PurchaseIntent`.
    ///         - **wallet.appcoins.io/checkout/success** or **/checkout/failure**
    ///             - Handles checkout result deep links and routes them to `PurchaseViewModel
    ///   - DeepLinks related to WebCheckout WebView
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
        Utils.log(
            "AppcSDK.handle(redirectURL: \(redirectURL)) at AppcSDK.swift",
            category: "Lifecycle",
            level: .info
        )
        
        AppcSDKInternal.initialize()
        
        if let redirectURL = redirectURL {
            Utils.log("Will handle redirectURL: \(redirectURL) at AppcSDK.swift:handle")
            
            if let host = redirectURL.host, host == "wallet.appcoins.io" {
                let queryItems = URLComponents(string: redirectURL.absoluteString)?.queryItems
                
                switch redirectURL.pathComponents[1] {
                case "default":
                    Utils.log("Default case at AppcSDK.swift:handle")
                    
                    if redirectURL.pathComponents.count > 2 {
                        if redirectURL.pathComponents[2] == "storefront" {
                            Utils.log("Storefront case at AppcSDK.swift:handle")
                            
                            var locale: AppcStorefront.Locale?
                            var marketplace: AppcStorefront.Marketplace?
                            
                            if let rawLocale = queryItems?.first(where: { $0.name == "locale" })?.value {
                                locale = AppcStorefront.Locale.fromRaw(raw: rawLocale)
                                if locale == nil { Utils.log("Invalid Storefront Locale: \(rawLocale) at AppcSDK.swift:handle") }
                            }
                            
                            if let rawMarketplace = queryItems?.first(where: { $0.name == "marketplace" })?.value {
                                marketplace = AppcStorefront.Marketplace.fromRaw(raw: rawMarketplace)
                                if marketplace == nil { Utils.log("Invalid Storefront Marketplace: \(rawMarketplace) at AppcSDK.swift:handle") }
                            }
                            
                            Utils.log("Configuring Storefront at AppcSDK.swift:handle")
                            AppcSDK.configure(locale: locale, marketplace: marketplace)
                        }
                    } else {
                        if let rawValue = queryItems?.first(where: { $0.name == "value" })?.value {
                            let value = rawValue.lowercased() == "true" ? true : false
                            SDKUseCases.shared.setSDKDefault(value: value)
                            Utils.log("SDK Default set to \(value) at AppcSDK.swift:handle")
                        }
                    }
                case "purchase":
                    Utils.log("Purchase case at AppcSDK.swift:handle")
                    
                    if let sku = queryItems?.first(where: { $0.name == "product" })?.value {
                        let discountPolicy = queryItems?.first(where: { $0.name == "discount_policy" })?.value.flatMap { DiscountPolicy(rawValue: $0) }
                        let oemID = queryItems?.first(where: { $0.name == "oemid" })?.value
                        
                        Task {
                            ProductUseCases.shared.getProduct(domain: BuildConfiguration.packageName, product: sku, discountPolicy: discountPolicy) { result in
                                
                                if case .success(let product) = result {
                                    Utils.log("Product found for SKU '\(sku)' at AppcSDK.swift:handle")
                                    PurchaseIntentManager.shared.set(intent: PurchaseIntent(product: product, discountPolicy: discountPolicy, oemID: oemID))
                                } else {
                                    Utils.log("Indirect purchase failed: product not found for SKU '\(sku)' at AppcSDK.swift:handle")
                                }
                            }
                        }
                    }
                case "checkout":
                    Utils.log("Checkout case at AppcSDK.swift:handle")
                    
                    if redirectURL.pathComponents.count > 2 {
                        switch redirectURL.pathComponents[2] {
                        case "success":
                            Utils.log("Checkout success case at AppcSDK.swift:handle")
                            PurchaseViewModel.shared.handleCheckoutSuccessDeeplink(deeplink: redirectURL)
                        case "failure":
                            Utils.log("Checkout failure case at AppcSDK.swift:handle")
                            PurchaseViewModel.shared.handleCheckoutFailureDeeplink(deeplink: redirectURL)
                        default:
                            break
                        }
                    }
                default:
                    Utils.log("Unknown case at AppcSDK.swift:handle")
                    PurchaseViewModel.shared.handleWebViewDeeplink(deeplink: redirectURL.absoluteString)
                }
            } else {
                Utils.log("Unknown case at AppcSDK.swift:handle")
                PurchaseViewModel.shared.handleWebViewDeeplink(deeplink: redirectURL.absoluteString)
            }
            
            return URLComponents(string: redirectURL.absoluteString)?.scheme == "\(BuildConfiguration.packageName).iap"
        } else {
            Utils.log("AppcSDK cannot recognize or process \(redirectURL) at AppcSDK.swift:handle")
            
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
