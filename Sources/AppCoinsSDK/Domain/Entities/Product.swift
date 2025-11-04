//
//  Product.swift
//
//
//  Created by aptoide on 15/05/2023.
//

import Foundation
@_implementationOnly import StoreKit

public struct Product: Codable {
    
    public let sku: String
    public let title: String
    public let description: String?
    public let priceCurrency: String
    public let priceValue: String
    public let priceLabel: String
    public let priceSymbol: String
    public let priceDiscountOriginal: String?
    public let priceDiscountPercentage: String?
    
    internal init(raw: ProductRaw) {
        self.sku = raw.sku
        self.title = raw.title
        self.description = raw.description
        self.priceCurrency = raw.price.currency
        self.priceValue = raw.price.value
        self.priceLabel = raw.price.label
        self.priceSymbol = raw.price.symbol
        self.priceDiscountOriginal = raw.price.discount?.original.value
        self.priceDiscountPercentage = raw.price.discount?.percentage
    }
    
    static public func products(
        domain: String = (Bundle.main.bundleIdentifier ?? ""),
        for identifiers: [String]? = nil
    ) async throws -> [Product] {
        let productUseCases: ProductUseCases = ProductUseCases.shared
        
        if let identifiers = identifiers {
            return try await withCheckedThrowingContinuation { continuation in
                productUseCases.getAllProducts(domain: domain) { result in
                    switch result {
                    case .success(let products):
                        var finalProducts : [Product] = []
                        for product in products {
                            if identifiers.contains(product.sku) {
                                finalProducts.append(product)
                            }
                        }
                        continuation.resume(returning: finalProducts)
                    case .failure(let failure):
                        switch failure {
                        case .failed(let message, let description, let request):
                            continuation.resume(
                                throwing:
                                    AppCoinsSDKError.systemError(
                                        message: message,
                                        description: description,
                                        request: request
                                    )
                            )
                        case .noInternet(let message, let description, let request):
                            continuation.resume(
                                throwing:
                                    AppCoinsSDKError.networkError(
                                        message: message,
                                        description: description,
                                        request: request
                                    )
                            )
                        case .purchaseVerificationFailed(let message, let description, let request):
                            continuation.resume(
                                throwing:
                                    AppCoinsSDKError.systemError(
                                        message: message,
                                        description: description,
                                        request: request
                                    )
                            )
                        }
                    }
                }
            }
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                productUseCases.getAllProducts(domain: domain) { result in
                    switch result {
                    case .success(let products):
                        continuation.resume(returning: products)
                    case .failure(let failure):
                        switch failure {
                        case .failed(let message, let description, let request):
                            continuation.resume(
                                throwing:
                                    AppCoinsSDKError.systemError(
                                        message: message,
                                        description: description,
                                        request: request
                                    )
                            )
                        case .noInternet(let message, let description, let request):
                            continuation.resume(
                                throwing:
                                    AppCoinsSDKError.networkError(
                                        message: message,
                                        description: description,
                                        request: request
                                    )
                            )
                        case .purchaseVerificationFailed(let message, let description, let request):
                            continuation.resume(
                                throwing:
                                    AppCoinsSDKError.systemError(
                                        message: message,
                                        description: description,
                                        request: request
                                    )
                            )
                        }
                    }
                }
            }
        }
    }
    
    public func purchase(
        domain: String = (Bundle.main.bundleIdentifier ?? ""),
        payload: String? = nil,
        orderID: String = String(Date.timeIntervalSinceReferenceDate)
    ) async -> PurchaseResult {
        guard SDKUseCases.shared.isSDKInitialized() else {
            return .failed(error:
                    .purchaseNotAllowed(
                        message: "Purchase Failed",
                        description: "AppcSDK not initialized at Product.swift:purchase. " +
                        "Make sure to call 'AppcSDK.handle(redirectURL)' whenever your app opens",
                        request: nil
                    )
            )
        }
        
        if await !AppcSDK.isAvailable() || PurchaseViewModel.shared.hasActivePurchase {
            return .failed(error:
                    .purchaseNotAllowed(
                        message: "Purchase Failed",
                        description: "AppcSDK not available or has active transaction at Product.swift:purchase",
                        request: nil
                    )
            )
        } else {
            AnalyticsUseCases.shared.recordStartConnection()
            
            DispatchQueue.main.async {
                SDKViewController.shared.presentPurchase()
                
                // product – the SKU product
                // domain – the app's domain registered in catappult
                // payload – information that the developer might want to pass with the transaction
                // orderID – a reference so that the developer can identify unique transactions
                PurchaseViewModel.shared.purchase(product: self, domain: domain, metadata: payload, reference: orderID)
            }
            
            let result = try? await withCheckedThrowingContinuation { continuation in
                var observer: NSObjectProtocol?
                observer = NotificationCenter.default.addObserver(forName: Notification.Name("APPCPurchaseResult"), object: nil, queue: nil) { notification in
                    if let userInfo = notification.userInfo {
                        if let status = userInfo["PurchaseResult"] as? PurchaseResult {
                            continuation.resume(returning: status)
                            
                            if let observer = observer {
                                NotificationCenter.default.removeObserver(observer)
                            }
                        }
                    }
                }
            }
            
            if let result = result {
                return result
            } else {
                return .failed(error:
                        .unknown(
                            message: "Purchase failed",
                            description: "Failed to retrieve required value: result is nil at Product.swift:purchase",
                            request: nil
                        )
                )
            }
        }
    }
    
    internal func indirectPurchase(
        domain: String = (Bundle.main.bundleIdentifier ?? ""),
        payload: String? = nil,
        orderID: String = String(Date.timeIntervalSinceReferenceDate),
        discountPolicy: DiscountPolicy? = nil,
        oemID: String? = nil
    ) async -> PurchaseResult {
        if PurchaseViewModel.shared.hasActivePurchase {
            return .failed(error:
                    .purchaseNotAllowed(
                        message: "Purchase Failed",
                        description: "AppcSDK not available or has active transaction at Product.swift:purchase",
                        request: nil
                    )
            )
        } else {
            AnalyticsUseCases.shared.recordStartConnection()
            
            DispatchQueue.main.async {
                SDKViewController.shared.presentPurchase()
                
                // product – the SKU product
                // domain – the app's domain registered in catappult
                // payload – information that the developer might want to pass with the transaction
                // orderID – a reference so that the developer can identify unique transactions
                // discountPolicy – discount policy for the purchase
                // oemID – developer identifier
                PurchaseViewModel.shared.purchase(
                    product: self,
                    domain: domain,
                    metadata: payload,
                    reference: orderID,
                    discountPolicy: discountPolicy,
                    oemID: oemID
                )
            }
            
            let result = try? await withCheckedThrowingContinuation { continuation in
                var observer: NSObjectProtocol?
                observer = NotificationCenter.default.addObserver(
                    forName: Notification.Name("APPCPurchaseResult"),
                    object: nil,
                    queue: nil
                ) {
                    notification in
                    
                    if let userInfo = notification.userInfo {
                        if let status = userInfo["PurchaseResult"] as? PurchaseResult {
                            continuation.resume(returning: status)
                            
                            if let observer = observer {
                                NotificationCenter.default.removeObserver(observer)
                            }
                        }
                    }
                }
            }
            
            if let result = result {
                return result
            } else {
                return .failed(error:
                        .unknown(
                            message: "Purchase failed",
                            description: "Failed to retrieve required value: result is nil at Product.swift:purchase",
                            request: nil
                        )
                )
            }
        }
    }
}
