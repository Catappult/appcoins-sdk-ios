//
//  Product.swift
//
//
//  Created by aptoide on 15/05/2023.
//

import Foundation
@_implementationOnly import StoreKit

public struct Product: Codable {

    public enum ProductType: String, Codable, Equatable, Hashable {
        case consumable
        case nonConsumable
        case autoRenewable
        case nonRenewable
    }

    public struct PurchaseOption: Hashable {
        internal enum Kind: Hashable {
            case appAccountToken(UUID)
        }
        internal let kind: Kind

        public static func appAccountToken(_ token: UUID) -> Product.PurchaseOption {
            PurchaseOption(kind: .appAccountToken(token))
        }
    }

    public enum PurchaseResult {
        case success(verificationResult: VerificationResult<Transaction>)
        case userCancelled
        case pending
    }

    public let id: String
    public let type: ProductType
    public let displayName: String
    public let description: String
    public let price: Decimal
    public let displayPrice: String
    public let isFamilyShareable: Bool

    internal init(raw: ProductRaw) {
        self.id = raw.sku
        self.type = .consumable
        self.displayName = raw.title
        self.description = raw.description ?? ""
        self.price = Decimal(string: raw.price.value) ?? 0
        self.displayPrice = raw.price.label
        self.isFamilyShareable = false
    }

    static public func products(for identifiers: [String]) async throws -> [Product] {
        Utils.log(
            "Product.products(for identifiers: \(identifiers)) at Product.swift",
            category: "Lifecycle",
            level: .default
        )

        let domain = Bundle.main.bundleIdentifier ?? ""
        let productUseCases: ProductUseCases = ProductUseCases.shared

        return try await withCheckedThrowingContinuation { continuation in
            productUseCases.getAllProducts(domain: domain) { result in
                switch result {
                case .success(let products):
                    let finalProducts = identifiers.isEmpty
                        ? []
                        : products.filter { identifiers.contains($0.id) }
                    Utils.log("Get products successful: \(finalProducts) at Product.swift:products")
                    continuation.resume(returning: finalProducts)
                case .failure(let failure):
                    Utils.log("Get products failed: \(failure) at Product.swift:products")
                    switch failure {
                    case .failed(let message, let description, let request):
                        continuation.resume(throwing: AppCoinsSDKError.systemError(message: message, description: description, request: request))
                    case .noInternet(let message, let description, let request):
                        continuation.resume(throwing: AppCoinsSDKError.networkError(message: message, description: description, request: request))
                    case .purchaseVerificationFailed(let message, let description, let request):
                        continuation.resume(throwing: AppCoinsSDKError.systemError(message: message, description: description, request: request))
                    }
                }
            }
        }
    }

    public func purchase(options: Set<Product.PurchaseOption> = []) async throws -> Product.PurchaseResult {
        let payload: String? = options.compactMap { option -> String? in
            guard case .appAccountToken(let token) = option.kind else { return nil }
            return token.uuidString
        }.first
        let orderID = String(Date.timeIntervalSinceReferenceDate)
        let domain = Bundle.main.bundleIdentifier ?? ""

        Utils.log(
            "Product.purchase(options: \(options)) at Product.swift",
            category: "Lifecycle",
            level: .default
        )

        guard SDKUseCases.shared.isSDKInitialized() else {
            Utils.log(
                "Purchase Failed: AppcSDK not initialized at Product.swift:purchase",
                level: .error
            )
            throw AppCoinsSDKError.purchaseNotAllowed(
                message: "Purchase Failed",
                description: "AppcSDK not initialized at Product.swift:purchase. " +
                    "Make sure to call 'AppcSDK.handle(redirectURL)' whenever your app opens",
                request: nil
            )
        }

        let isAvailable = await AppcSDK.isAvailable()
        guard isAvailable else {
            Utils.log(
                "Purchase Failed: AppcSDK not available at Product.swift:purchase",
                level: .error
            )
            throw AppCoinsSDKError.purchaseNotAllowed(
                message: "Purchase Failed",
                description: "AppcSDK not available at Product.swift:purchase",
                request: nil
            )
        }

        guard !PurchaseViewModel.shared.hasActivePurchase else {
            Utils.log(
                "Purchase Failed: AppcSDK has active transaction at Product.swift:purchase",
                level: .error
            )
            throw AppCoinsSDKError.purchaseNotAllowed(
                message: "Purchase Failed",
                description: "AppcSDK has active transaction at Product.swift:purchase",
                request: nil
            )
        }

        Utils.log(
            "Starting purchase with domain: \(domain) at Product.swift:purchase",
            category: "Lifecycle",
            level: .default
        )

        AnalyticsUseCases.shared.recordStartConnection()

        DispatchQueue.main.async {
            SDKViewController.shared.presentPurchase()
            PurchaseViewModel.shared.purchase(product: self, domain: domain, metadata: payload, reference: orderID)
        }

        return try await withCheckedThrowingContinuation { continuation in
            var observer: NSObjectProtocol?
            observer = NotificationCenter.default.addObserver(
                forName: Notification.Name("APPCPurchaseResult"),
                object: nil,
                queue: nil
            ) { notification in
                if let userInfo = notification.userInfo,
                   let status = userInfo["PurchaseResult"] as? AppCoinsSDK.PurchaseResult {
                    if let observer = observer { NotificationCenter.default.removeObserver(observer) }
                    switch status {
                    case .success(let vr): continuation.resume(returning: .success(verificationResult: vr))
                    case .pending: continuation.resume(returning: .pending)
                    case .userCancelled: continuation.resume(returning: .userCancelled)
                    case .failed(let error): continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    public var latestTransaction: VerificationResult<Transaction>? {
        get async { await Transaction.latest(for: id) }
    }

    public var currentEntitlement: VerificationResult<Transaction>? {
        get async { await Transaction.latest(for: id) }
    }

}
