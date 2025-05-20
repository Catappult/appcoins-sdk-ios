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
        if BuildConfiguration.isDev {
            return true
        }
        
        if let isDefault = SDKUseCases.shared.isDefault() {
            return isDefault
        }
        
        let usAllowed = await isAvailableInUS()
        let euAllowed = await isAvailableInEU()
        return usAllowed || euAllowed
    }
    
    /// Checks availability of the AppcSDK in the United States storefront.
    ///
    /// - If `AppCoinsDevTools` is enabled and a default locale is set:
    ///   - Returns `true` if the default locale equals `.USA`.
    /// - Otherwise:
    ///   - On iOS versions prior to 15.0, returns `Locale.current.regionCode == "US"`.
    ///   - On iOS 15.0 and later, attempts to fetch `StoreKit.Storefront.current`:
    ///     - Returns `true` if `storefront?.countryCode == "USA"`.
    ///     - Falls back to the locale check on error.
    ///
    /// - Returns: `true` if the SDK can be used in the US, `false` otherwise.
    static internal func isAvailableInUS() async -> Bool {
        if AppcSDK.configuration.isAppCoinsDevToolsEnabled, let defaultLocale = AppcSDK.configuration.storefront?.locale {
            return defaultLocale == AppcStorefront.Locale.USA
        }
        
        let localeIsUS = (Locale.current.regionCode == "US")
        
        // On older OS versions just return the locale
        guard #available(iOS 15.0, *) else {
            return localeIsUS
        }
        
        do {
            let storefront = try await StoreKit.Storefront.current
            return (storefront?.countryCode == "PT")
        } catch {
            // If the Storefront lookup fails, fall back to the locale
            return localeIsUS
        }
    }

    /// Checks availability of the AppcSDK in European Union marketplaces.
    ///
    /// - If `AppCoinsDevTools` is enabled and a default locale is set:
    ///   - Returns `false` if the locale is outside the EU.
    ///   - If a default marketplace override exists:
    ///     - Returns `true` for `.aptoide`.
    ///     - Returns `false` for `.apple`.
    /// - Otherwise:
    ///   - On iOS versions prior to 17.4, always returns `false`.
    ///   - On iOS 17.4 and later, fetches `AppDistributor.current`:
    ///     - Returns `false` for `.appStore`.
    ///     - Returns `true` if `marketplace == "com.aptoide.ios.store"`.
    ///     - Returns `true` for any other non-App Store marketplace.
    ///   - Returns `false` on error.
    ///
    /// - Returns: `true` if the SDK can be used in the EU, `false` otherwise.
    static internal func isAvailableInEU() async -> Bool {
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
                        Task {
                            guard let product = await try? Product.products(for: [sku]).first else { return }
                            PurchaseIntentManager.shared.set(intent: PurchaseIntent(product: product))
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
