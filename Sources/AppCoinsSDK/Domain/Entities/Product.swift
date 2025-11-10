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
        Utils.log(
            "Product.products(domain, for indentifiers) at Product.swift",
            category: "Lifecycle",
            level: .info
        )
        
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
                        
                        Utils.log("Get all produts with identifiers successful: \(finalProducts) at Product.swift:products")
                        
                        continuation.resume(returning: finalProducts)
                    case .failure(let failure):
                        Utils.log("Get all produts with identifiers failed: \(failure) at Product.swift:products")
                        
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
                        Utils.log("Get all products without identifiers successful: \(products) at Product.swift:products")
                        continuation.resume(returning: products)
                    case .failure(let failure):
                        Utils.log("Get all produts without identifiers failed: \(failure) at Product.swift:products")
                        
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
        Utils.log(
            "Product.purchase(domain, payload, orderID) with domain: \(domain) at Product.swift",
            category: "Lifecycle",
            level: .info
        )
        
        guard SDKUseCases.shared.isSDKInitialized() else {
            Utils.log(
                "Purchase Failed: AppcSDK not initialized at Product.swift:purchase",
                level: .error
            )
            
            return .failed(error:
                    .purchaseNotAllowed(
                        message: "Purchase Failed",
                        description: "AppcSDK not initialized at Product.swift:purchase. " +
                        "Make sure to call 'AppcSDK.handle(redirectURL)' whenever your app opens",
                        request: nil
                    )
            )
        }
        
        let isAvailable = await !AppcSDK.isAvailable()
        let hasActivePurchase = PurchaseViewModel.shared.hasActivePurchase
        
        if !isAvailable || hasActivePurchase {
            Utils.log(
                "Purchase Failed: AppcSDK availability: \(isAvailable) or " +
                "has active transaction: \(hasActivePurchase) at Product.swift:purchase",
                level: .error
            )
            
            return .failed(error:
                    .purchaseNotAllowed(
                        message: "Purchase Failed",
                        description: "AppcSDK not available or has active transaction at Product.swift:purchase",
                        request: nil
                    )
            )
        } else {
            Utils.log(
                "Starting purchase with domain: \(domain) at Product.swift:purchase",
                category: "Lifecycle",
                level: .info
            )
            
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
                Utils.log("Purchase result: \(result) at Product.swift:purchase")
                
                return result
            } else {
                Utils.log("Purchase failed: result is nil at Product.swift:purchase", level: .error)
                
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
        Utils.log(
            "Product.indirectPurchase(domain, payload, orderID, discountPolicy, oemID) with domain: \(domain) at Product.swift",
            category: "Lifecycle",
            level: .info
        )
        
        if PurchaseViewModel.shared.hasActivePurchase {
            Utils.log(
                "Indirect purchase failed: AppcSDK has active transaction at Product.swift:indirectPurchase",
                level: .error
            )
            
            return .failed(error:
                    .purchaseNotAllowed(
                        message: "Purchase Failed",
                        description: "AppcSDK not available or has active transaction at Product.swift:indirectPurchase",
                        request: nil
                    )
            )
        } else {
            Utils.log(
                "Starting indirect purchase with domain: \(domain) at Product.swift:indirectPurchase",
                category: "Lifecycle",
                level: .info
            )
            
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
                Utils.log("Indirect purchase result: \(result) at Product.swift:indirectPurchase")
                
                return result
            } else {
                Utils.log("Indirect purchase failed: result is nil at Product.swift:indirectPurchase")
                
                return .failed(error:
                        .unknown(
                            message: "Purchase failed",
                            description: "Failed to retrieve required value: result is nil at Product.swift:indirectPurchase",
                            request: nil
                        )
                )
            }
        }
    }
}
