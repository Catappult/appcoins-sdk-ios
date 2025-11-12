//
//  Purchase.swift
//
//
//  Created by aptoide on 24/05/2023.
//

import Foundation
@_implementationOnly import StoreKit

public class Purchase: Codable {
    
    public let uid: String
    public let sku: String
    public var state: String
    public let orderUid: String
    public let payload: String?
    public let created: String
    public let verification: PurchaseVerification
    
    public class PurchaseVerification: Codable {
        public let type: String
        public let data: PurchaseVerificationData
        public let signature: String
        
        internal init(raw: PurchaseVerificationRaw) {
            self.type = raw.type
            self.signature = raw.signature
            self.data = PurchaseVerificationData(raw: raw.data)
        }
    }
    
    public class PurchaseVerificationData: Codable {
        public let orderId: String
        public let packageName: String
        public let productId: String
        public let purchaseTime: Int
        public let purchaseToken: String
        public let purchaseState: Int
        public let developerPayload: String
        
        internal init(raw: PurchaseVerificationDataRaw) {
            self.orderId = raw.orderId
            self.packageName = raw.packageName
            self.productId = raw.productId
            self.purchaseTime = raw.purchaseTime
            self.purchaseToken = raw.purchaseToken
            self.purchaseState = raw.purchaseState
            self.developerPayload = raw.developerPayload
        }
    }
    
    internal init(raw: PurchaseRaw) {
        self.uid = raw.uid
        self.sku = raw.sku
        self.state = raw.state
        self.orderUid = raw.order_uid
        self.payload = raw.payload
        self.created = raw.created
        self.verification = PurchaseVerification(raw: raw.verification)
    }

    internal static func verify(
        domain: String = (Bundle.main.bundleIdentifier ?? ""),
        purchaseUID: String,
        completion: @escaping (Result<Purchase, AppCoinsSDKError>
        ) -> Void
    ) {
        Utils.log(
            "Purchase.verify(domain: \(domain), purchaseUID: \(purchaseUID)) at Purchase.swift",
            category: "Lifecycle",
            level: .info
        )
        
        Utils.log("Getting wallet list at Purchase.swift:verify")
        
        WalletUseCases.shared.getWalletList() { walletList in
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "verify-queue", attributes: .concurrent)
            
            var isVerified = false
            var verifiedPurchase: Purchase? = nil
            var error: AppCoinsSDKError? = nil
            
            for wallet in walletList {
                group.enter()
                queue.async {
                    TransactionUseCases.shared.verifyPurchase(domain: domain, uid: purchaseUID, wa: wallet) {
                        result in
                        
                        switch result {
                        case .success(let purchase):
                            isVerified = true
                            verifiedPurchase = purchase
                        case .failure(let failure):
                            // If no Wallet can verify the purchase then the error thrown should be the one for the last wallet made active
                            if wallet.getWalletAddress() == walletList.last?.getWalletAddress() {
                                switch failure {
                                case .failed(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                case .noInternet(let message, let description, let request):
                                    error = AppCoinsSDKError.networkError(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                case .purchaseVerificationFailed(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                }
                            }
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                if isVerified, let verifiedPurchase = verifiedPurchase {
                    Utils.log("Purchase verified for domain: \(domain) at Purchase.swift:verify")
                    completion(.success(verifiedPurchase))
                    return
                }
                
                if let error = error {
                    Utils.log(
                        "Purchase verification failed for domain: \(domain) with error: \(error) at Purchase.swift:verify",
                        level: .error
                    )
                    completion(.failure(error))
                } else {
                    Utils.log("Purchase verification failed for domain: \(domain) with an unknown error at Purchase.swift:verify")
                    completion(.failure(
                        AppCoinsSDKError.unknown(
                            message: "Failed to verify purchase",
                            description: "The purchase was not verified at Purchase.swift:verify"
                        ))
                    )
                }
            }
        }
    }
    
    // only accessible internally – the SDK acknowledges the purchase
    internal func acknowledge(domain: String = (Bundle.main.bundleIdentifier ?? ""), completion: @escaping (AppCoinsSDKError?) -> Void) {
        Utils.log(
            "Purchase.acknowledge(domain: \(domain)) at Purchase.swift",
            category: "Lifecycle",
            level: .info
        )
        
        Utils.log("Getting wallet list at Purchase.swift:acknowledge")
        
        WalletUseCases.shared.getWalletList() { walletList in
            
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "acknowledge-queue", attributes: .concurrent)
            
            var isAcknowledged = false
            var error: AppCoinsSDKError? = nil
            
            for wallet in walletList {
                group.enter()
                queue.async {
                    TransactionUseCases.shared.acknowledgePurchase(domain: domain, uid: self.uid, wa: wallet) {
                        result in
                        
                        switch result {
                        case .success(_):
                            self.state = "ACKNOWLEDGED"
                            isAcknowledged = true
                        case .failure(let failure):
                            // If no Wallet can acknowledge the purchase then the error thrown should be the one for the last wallet made active
                            if wallet.getWalletAddress() == walletList.last?.getWalletAddress() {
                                switch failure {
                                case .failed(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                case .noInternet(let message, let description, let request):
                                    error = AppCoinsSDKError.networkError(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                case .general(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                case .noBillingAgreement(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                case .timeOut(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                }
                            }
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                if isAcknowledged {
                    Utils.log("Purchase acknowledged for domain: \(domain) at Purchase.swift:acknowledge")
                    completion(nil)
                    return
                }
                
                if let error = error {
                    Utils.log(
                        "Purchase acknowledge for domain: \(domain) failed with error: \(error) at Purchase.swift:acknowledge",
                        level: .error
                    )
                    completion(error)
                } else {
                    Utils.log(
                        "Purchase acknowledge for domain: \(domain) failed with an unknown error at Purchase.swift:acknowledge",
                        level: .error
                    )
                    completion(AppCoinsSDKError.unknown(
                        message: "Failed to acknowledge purchase",
                        description: "The purchase was not acknowledged at Purchase.swift:acknowledge"
                    ))
                }
            }
        }
    }
    
    // accessible by the developer – the app consumes the purchase and attributes the item to the user
    public func finish(domain: String = (Bundle.main.bundleIdentifier ?? "")) async throws {
        Utils.log(
            "Purchase.finish(domain: \(domain)) at Purchase.swift",
            category: "Lifecycle",
            level: .info
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            
            WalletUseCases.shared.getWalletList() { walletList in
                
                let group = DispatchGroup()
                let queue = DispatchQueue(label: "consume-queue", attributes: .concurrent)
                
                var isConsumed = false
                var error: AppCoinsSDKError? = nil
                
                for wallet in walletList {
                    group.enter()
                    queue.async {
                        TransactionUseCases.shared.consumePurchase(domain: domain, uid: self.uid, wa: wallet) {
                            result in
                            switch result {
                            case .success(_):
                                self.state = "CONSUMED"
                                isConsumed = true
                            case .failure(let failure):
                                // If no Wallet can finish the purchase then the error thrown should be the one for the last wallet made active
                                if wallet.getWalletAddress() == walletList.last?.getWalletAddress() {
                                    switch failure {
                                    case .failed(let message, let description, let request):
                                        error = AppCoinsSDKError.systemError(
                                            debugInfo: DebugInfo(
                                                message: message,
                                                description: description,
                                                request: request
                                            )
                                        )
                                    case .noInternet(let message, let description, let request):
                                        error = AppCoinsSDKError.networkError(
                                            debugInfo: DebugInfo(
                                                message: message,
                                                description: description,
                                                request: request
                                            )
                                        )
                                    case .general(let message, let description, let request):
                                        error = AppCoinsSDKError.systemError(
                                            debugInfo: DebugInfo(
                                                message: message,
                                                description: description,
                                                request: request
                                            )
                                        )
                                    case .noBillingAgreement(let message, let description, let request):
                                        error = AppCoinsSDKError.systemError(
                                            debugInfo: DebugInfo(
                                                message: message,
                                                description: description,
                                                request: request
                                            )
                                        )
                                    case .timeOut(let message, let description, let request):
                                        error = AppCoinsSDKError.systemError(
                                            debugInfo: DebugInfo(
                                                message: message,
                                                description: description,
                                                request: request
                                            )
                                        )
                                    }
                                }
                            }
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    if isConsumed {
                        Utils.log("Consumed purchase for domain: \(domain) at Purchase.swift:finish")
                        continuation.resume()
                        return
                    }
                    
                    if let error = error {
                        Utils.log(
                            "Purchase could not be consumed for domain: \(domain) with error: \(error) at Purchase.swift:finish",
                            level: .error
                        )
                        continuation.resume(throwing: error)
                    } else {
                        Utils.log(
                            "Purchase could not be consumed for domain: \(domain) with an unknown error at Purchase.swift:finish",
                            level: .error
                        )
                        continuation.resume(throwing:
                                                AppCoinsSDKError.unknown(
                                                    message: "Failed to complete the purchase process",
                                                    description: "The purchase was not consumed and the item was not attributed to the user at Purchase.swift:finish"
                        ))
                    }
                }
            }
        }
    }
    
    // get all the user's purchases
    public static func all(domain: String = (Bundle.main.bundleIdentifier ?? "")) async throws -> [Purchase] {
        Utils.log(
            "Purchase.all(domain: \(domain)) at Purchase.swift",
            category: "Lifecycle",
            level: .info
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            Utils.log("Getting wallet list at Purchase.swift:all")
            
            WalletUseCases.shared.getWalletList() { walletList in
                
                let group = DispatchGroup()
                let queue = DispatchQueue(label: "get-all-purchases-queue", attributes: .concurrent)
                
                var purchaseList : [Purchase] = []
                var error : AppCoinsSDKError? = nil
                
                for wallet in walletList {
                    group.enter()
                    queue.async {
                        TransactionUseCases.shared.getAllPurchases(domain: domain, wa: wallet) {
                            result in
                            
                            switch result {
                            case .success(let purchases):
                                purchaseList += purchases
                            case .failure(let productServiceError):
                                switch productServiceError {
                                case .failed(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                case .noInternet(let message, let description, let request):
                                    error = AppCoinsSDKError.networkError(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                case .purchaseVerificationFailed(let message, let description, let request):
                                    error = AppCoinsSDKError.unknown(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                }
                            }
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    if let error = error {
                        Utils.log("Get all purchases for domain: \(domain) failed with error: \(error) at Purchase.swift:all")
                        continuation.resume(throwing: error)
                    } else {
                        Utils.log("Sorting all purchases at Purchase.swift:all")
                        let sortedPurchases = sortPurchasesByCreated(purchases: purchaseList)
                        
                        Utils.log("Get all purchases successful for domain: \(domain) at Purchase.swift:all")
                        continuation.resume(returning: sortedPurchases)
                    }
                }
            }
        }
    }
    
    public static func latest(domain: String = (Bundle.main.bundleIdentifier ?? ""), sku: String) async throws -> Purchase? {
        Utils.log(
            "Purchase.latest(domain: \(domain)) at Purchase.swift",
            category: "Lifecycle",
            level: .info
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            Utils.log("Getting wallet list at Purchase.swift:latest")
            
            WalletUseCases.shared.getWalletList { walletList in
                
                let group = DispatchGroup()
                let queue = DispatchQueue(label: "get-latest-purchase-queue", attributes: .concurrent)
                
                var purchaseList : [Purchase] = []
                var error : AppCoinsSDKError? = nil
                
                for wallet in walletList {
                    group.enter()
                    queue.async {
                        TransactionUseCases.shared.getLatestPurchase(domain: domain, sku: sku, wa: wallet) {
                            result in
                            switch result {
                            case .success(let purchase):
                                if let purchase = purchase { purchaseList.append(purchase) }
                            case .failure(let productServiceError):
                                switch productServiceError {
                                case .failed(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                case .noInternet(let message, let description, let request):
                                    error = AppCoinsSDKError.networkError(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                case .purchaseVerificationFailed(let message, let description, let request):
                                    error = AppCoinsSDKError.unknown(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                }
                            }
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    if let error = error {
                        Utils.log(
                            "Get latest purchase for domain: \(domain) failed with error: \(error) at Purchase.swift:latest",
                            level: .error
                        )
                        continuation.resume(throwing: error)
                    } else {
                        Utils.log("Sorting purchase list at Purchase.swift:latest")
                        let sortedPurchases = sortPurchasesByCreated(purchases: purchaseList)
                        
                        Utils.log("Returning latest purchase for domain: \(domain) at Purchase.swift:latest")
                        continuation.resume(returning: sortedPurchases.first)
                    }
                }
            }
        }
    }
    
    // we consider unfinished purchases any purchase that have neither been acknowledged nor consumed
    public static func unfinished(domain: String = (Bundle.main.bundleIdentifier ?? "")) async throws -> [Purchase] {
        Utils.log(
            "Purchase.unfinished(domain: \(domain)) at Purchase.swift",
            category: "Lifecycle",
            level: .info
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            Utils.log("Getting wallet list at Purchase.swift:unfinished")
            
            WalletUseCases.shared.getWalletList { walletList in
                
                let group = DispatchGroup()
                let queue = DispatchQueue(label: "get-unfinished-purchases-queue", attributes: .concurrent)
                
                var purchaseList : [Purchase] = []
                var error : AppCoinsSDKError? = nil
                
                for wallet in walletList {
                    group.enter()
                    queue.async {
                        TransactionUseCases.shared.getPurchasesByState(domain: domain, state: ["PENDING", "ACKNOWLEDGED"], wa: wallet) {
                            result in
                            switch result {
                            case .success(let purchases):
                                purchaseList += purchases
                            case .failure(let productServiceError):
                                switch productServiceError {
                                case .failed(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                case .noInternet(let message, let description, let request):
                                    error = AppCoinsSDKError.networkError(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                case .purchaseVerificationFailed(let message, let description, let request):
                                    error = AppCoinsSDKError.unknown(
                                        debugInfo: DebugInfo(
                                            message: message,
                                            description: description,
                                            request: request
                                        )
                                    )
                                }
                            }
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    if let error = error {
                        Utils.log(
                            "Purchase unfinished for domain: \(domain) with error: \(error) at Purchase.swift:unfinished",
                            level: .error
                        )
                        continuation.resume(throwing: error)
                    } else {
                        Utils.log("Sorting purchase list at Purchase.swift:unfinished")
                        let sortedPurchases = sortPurchasesByCreated(purchases: purchaseList)
                        
                        Utils.log("Returning sorted purchase list at Purchase.swift:unfinished")
                        continuation.resume(returning: sortedPurchases)
                    }
                }
            }
        }
    }
    
    private static func sortPurchasesByCreated(purchases: [Purchase]) -> [Purchase] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        let sortedPurchases = purchases.sorted {
            guard let date1 = formatter.date(from: $0.created) else { return false }
            guard let date2 = formatter.date(from: $1.created) else { return true }
            return date1 > date2
        }
        return sortedPurchases
    }
    
    // Defines a Stream that will emit updates for indirect IAP
    private static var purchaseContinuation: AsyncStream<PurchaseIntent>.Continuation?
    private static let purchaseStream: AsyncStream<PurchaseIntent> = {
        AsyncStream { continuation in purchaseContinuation = continuation }
    }()
    
    public static var updates: AsyncStream<PurchaseIntent> {
        return purchaseStream
    }

    internal static func send(_ intent: PurchaseIntent) {
        purchaseContinuation?.yield(intent)
    }
    
    public static var intent: PurchaseIntent? {
        return PurchaseIntentManager.shared.current
    }
}
