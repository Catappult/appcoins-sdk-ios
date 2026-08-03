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

    /// It initializes internal processes of the AppCoins SDK.
    /// Should be called at all entrypoints of the application.
    static public func initialize() {
        Utils.log(
            "AppcSDK.initialize() at AppcSDK.swift",
            category: "Lifecycle",
            level: .default
        )

        Task {
            if await AppcSDK.isAvailable() {
                MMPUseCases.shared.getAttribution()
                AnalyticsUseCases.shared.initialize()
                if #available(iOS 26, *) {
                    ExternalPurchaseUseCases.shared.flushReports()
                }
            }
        }
        SDKUseCases.shared.setSDKInitialized()

        Utils.log("AppcSDK initialized with version \(BuildConfiguration.sdkShortVersion)(\(BuildConfiguration.sdkBuildNumber)) at AppcSDK.swift:initialize")
    }

    /// Checks whether the AppcSDK should be enabled in the current environment.
    ///
    /// - If `BuildConfiguration.isDev` always returns `true`.
    /// - In `.automatic` mode (default):
    ///    - On iOS 17.4+ uses `AppDistributor.current`:
    ///       - returns `false` for `.appStore` and `.testFlight`
    ///       - returns `true` for any other non-App Store case
    ///    - On older OS returns `false`.
    /// - In `.appCoins` mode: always returns `true`, unless distributed via Apple's App Store.
    /// - In `.apple` mode: always returns `false`.
    ///
    /// - Returns: `true` if the SDK is available, `false` otherwise.
    static public func isAvailable() async -> Bool {
        Utils.log(
            "AppcSDK.isAvailable() at AppcSDK.swift",
            category: "Lifecycle",
            level: .default
        )

        if BuildConfiguration.isDev {
            Utils.log("AppcSDK is available in dev mode at AppcSDK.swift:isAvailable")
            return true
        }

        let mode = SDKUseCases.shared.getSDKAvailabilityMode()
        Utils.log("SDKAvailabilityMode: \(mode.displayName) at AppcSDK.swift:isAvailable")

        switch mode {
        case .apple:
            Utils.log("AppcSDK unavailable: Apple mode at AppcSDK.swift:isAvailable")
            return false

        case .appCoins:
            if await isAppleAppStoreDistribution() {
                Utils.log("AppcSDK unavailable: AppCoins mode locked by Apple App Store distribution at AppcSDK.swift:isAvailable")
                return false
            }
            Utils.log("AppcSDK available: AppCoins mode at AppcSDK.swift:isAvailable")
            return true

        case .automatic:
            return await checkAutomaticAvailability()
        }
    }

    /// Handles the redirect URL and routes it to the appropriate handler.
    /// Should be called at all entrypoints of the application.
    ///
    /// Supported URL patterns for `wallet.appcoins.io`:
    /// - `/default/info`: shows a popup with the current `SDKAvailabilityMode` for ~3 seconds.
    /// - `/default/mode?value=appcoins|apple|automatic`: sets the availability mode (no-op when distributed via Apple's App Store).
    /// - `/checkout/success` or `/checkout/failure`: handles checkout result deep links.
    ///
    /// - Parameters:
    ///   - redirectURL: The URL received from a deep link into the application.
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
            level: .default
        )

        if let redirectURL = redirectURL {
            Utils.log("Will handle redirectURL: \(redirectURL) at AppcSDK.swift:handle")

            if let host = redirectURL.host, host == "wallet.appcoins.io" {
                let queryItems = URLComponents(string: redirectURL.absoluteString)?.queryItems

                switch redirectURL.pathComponents[1] {
                case "default":
                    Utils.log("Default case at AppcSDK.swift:handle")

                    if redirectURL.pathComponents.count > 2 {
                        switch redirectURL.pathComponents[2] {
                        case "info":
                            Utils.log("Info case at AppcSDK.swift:handle")
                            let mode = SDKUseCases.shared.getSDKAvailabilityMode()
                            Task { @MainActor in SDKModeInfoPopup.show(mode: mode) }

                        case "mode":
                            Utils.log("Mode case at AppcSDK.swift:handle")
                            if let rawMode = queryItems?.first(where: { $0.name == "value" })?.value,
                               let mode = SDKAvailabilityMode(rawValue: rawMode.lowercased()) {
                                Task {
                                    if await isAppleAppStoreDistribution() {
                                        Utils.log("Mode change rejected: locked by Apple App Store distribution at AppcSDK.swift:handle")
                                    } else {
                                        SDKUseCases.shared.setSDKAvailabilityMode(mode: mode)
                                        Utils.log("SDKAvailabilityMode set to \(mode.displayName) at AppcSDK.swift:handle")
                                    }
                                }
                            } else {
                                Utils.log("Invalid mode value at AppcSDK.swift:handle")
                            }

                        default:
                            Utils.log("Unknown default subpath at AppcSDK.swift:handle")
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
            Utils.log("AppcSDK cannot recognize or process redirectURL: \(redirectURL) at AppcSDK.swift:handle")
            return false
        }
    }

    private static func checkAutomaticAvailability() async -> Bool {
        do {
            guard #available(iOS 17.4, *) else {
                Utils.log("AppcSDK isn't available for iOS versions below iOS 17.4 at AppcSDK.swift:isAvailable")
                return false
            }

            #if targetEnvironment(simulator)
                Utils.log("Can't validate App Distributor on Simulator. To test different billings " +
                          "(Apple vs. Aptoide) use an actual device or set the SDK availability mode.")
                return true
            #else
                let distributor = try await AppDistributor.current
                switch distributor {
                case .appStore:
                    Utils.log("AppcSDK isn't available for storefront: \(distributor) at AppcSDK.swift:isAvailable")
                    return false
                case .testFlight:
                    Utils.log("AppcSDK isn't available for storefront: \(distributor) at AppcSDK.swift:isAvailable")
                    return false
                case .marketplace:
                    Utils.log("AppcSDK is available for storefront: \(distributor) at AppcSDK.swift:isAvailable")
                    return true
                case .web:
                    Utils.log("AppcSDK is available for storefront: \(distributor) at AppcSDK.swift:isAvailable")
                    return true
                case .other:
                    Utils.log("AppcSDK is available for storefront: \(distributor) at AppcSDK.swift:isAvailable")
                    return true
                default:
                    Utils.log("AppcSDK isn't available for storefront: \(distributor) at AppcSDK.swift:isAvailable")
                    return false
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

    private static func isAppleAppStoreDistribution() async -> Bool {
        guard #available(iOS 17.4, *) else { return false }
        #if targetEnvironment(simulator)
            return false
        #else
            if case .appStore = try? await AppDistributor.current {
                return true
            }
            return false
        #endif
    }
}
