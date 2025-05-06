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
    
    public static func chooseProvider() async -> PurchaseProvider? {
        guard await AppcSDK.isAvailableInUS() else { return .aptoide }
        
        DispatchQueue.main.async {
            SDKViewController.presentProvider()
            
            ProviderViewModel.shared.showProviderChoice()
        }
        
        let result: PurchaseProvider? = try? await withCheckedThrowingContinuation { continuation in
            var observer: NSObjectProtocol?
            observer = NotificationCenter.default.addObserver(forName: Notification.Name("APPCProviderChoice"), object: nil, queue: nil) { notification in
                guard let userInfo = notification.userInfo, let provider = userInfo["ProviderChoice"] as? PurchaseProvider else {
                    continuation.resume(returning: nil)
                    if let observer = observer { NotificationCenter.default.removeObserver(observer) }
                    return
                }
                
                continuation.resume(returning: provider)
                if let observer = observer { NotificationCenter.default.removeObserver(observer) }
                return
            }
        }
        
        return result
    }
    
    internal static func verify(domain: String = (Bundle.main.bundleIdentifier ?? ""), purchaseUID: String, completion: @escaping (Result<Purchase, AppCoinsSDKError>) -> Void ) {
        
        WalletUseCases.shared.getWallet() {
            result in
            
            switch result {
            case .success(let wallet):
                TransactionUseCases.shared.verifyPurchase(domain: domain, uid: purchaseUID, wa: wallet) {
                    result in
                    
                    switch result {
                    case .success(let purchase):
                        completion(.success(purchase))
                    case .failure(let error):
                        switch error {
                        case .failed(let message, let description, let request):
                            completion(.failure(AppCoinsSDKError.systemError(debugInfo: DebugInfo(message: message, description: description, request: request))))
                        case .noInternet(let message, let description, let request):
                            completion(.failure(AppCoinsSDKError.networkError(debugInfo: DebugInfo(message: message, description: description, request: request))))
                        case .purchaseVerificationFailed(let message, let description, let request):
                            completion(.failure(AppCoinsSDKError.systemError(debugInfo: DebugInfo(message: message, description: description, request: request))))
                        }
                    }
                }
            case .failure(let error):
                switch error {
                case .failed(let message, let description, let request):
                    completion(.failure(AppCoinsSDKError.systemError(debugInfo: DebugInfo(message: message, description: description, request: request))))
                case .noInternet(let message, let description, let request):
                    completion(.failure(AppCoinsSDKError.networkError(debugInfo: DebugInfo(message: message, description: description, request: request))))
                }
            }
        }
    }
    
    // only accessible internally – the SDK acknowledges the purchase
    internal func acknowledge(domain: String = (Bundle.main.bundleIdentifier ?? ""), completion: @escaping (AppCoinsSDKError?) -> Void) {
        
        WalletUseCases.shared.getWallet() {
            result in
            
            switch result {
            case .success(let wallet):
                TransactionUseCases.shared.acknowledgePurchase(domain: domain, uid: self.uid, wa: wallet) {
                    result in
                    
                    switch result {
                    case .success(_):
                        self.state = "ACKNOWLEDGED"
                        completion(nil)
                    case .failure(let error):
                        switch error {
                        case .failed(let message, let description, let request):
                            completion(AppCoinsSDKError.systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                        case .noInternet(let message, let description, let request):
                            completion(AppCoinsSDKError.networkError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                        case .general(let message, let description, let request):
                            completion(AppCoinsSDKError.systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                        case .noBillingAgreement(let message, let description, let request):
                            completion(AppCoinsSDKError.systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                        case .timeOut(let message, let description, let request):
                            completion(AppCoinsSDKError.systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                        }
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    // accessible by the developer – the app consumes the purchase and attributes the item to the user
    public func finish(domain: String = (Bundle.main.bundleIdentifier ?? "")) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            
            WalletUseCases.shared.getWalletList() { walletList in
                
                let group = DispatchGroup()
                let queue = DispatchQueue(label: "consume-queue", attributes: .concurrent)
                
                var isConsumed = false
                var isNetworkError = false
                var error: AppCoinsSDKError? = nil
                
                for wallet in walletList {
                    group.enter()
                    queue.sync {
                        TransactionUseCases.shared.consumePurchase(domain: domain, uid: self.uid, wa: wallet) {
                            result in
                            switch result {
                            case .success(_):
                                self.state = "CONSUMED"
                                isConsumed = true
                            case .failure(let failure):
                                switch failure {
                                case .noInternet(let message, let description, let request):
                                    error = AppCoinsSDKError.networkError(debugInfo: DebugInfo(message: message, description: description, request: request))
                                    isNetworkError = true
                                default: break
                                }
                            }
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    if isConsumed { continuation.resume() }
                    else if isNetworkError, let error = error { continuation.resume(throwing: error) }
                    else { continuation.resume(throwing: AppCoinsSDKError.unknown(message: "Failed to complete the purchase process", description: "The purchase was not consumed and the item was not attributed to the user at Purchase.swift:finish")) }
                }
            }
        }
    }
    
    // get all the user's purchases
    public static func all(domain: String = (Bundle.main.bundleIdentifier ?? "")) async throws -> [Purchase] {
        return try await withCheckedThrowingContinuation { continuation in
            
            WalletUseCases.shared.getWalletList() { walletList in
                
                let group = DispatchGroup()
                let queue = DispatchQueue(label: "get-all-purchases-queue", attributes: .concurrent)
                
                var purchaseList : [Purchase] = []
                var error : AppCoinsSDKError? = nil
                
                for wallet in walletList {
                    group.enter()
                    queue.sync {
                        TransactionUseCases.shared.getAllPurchases(domain: domain, wa: wallet) {
                            result in
                            
                            switch result {
                            case .success(let purchases):
                                purchaseList += purchases
                            case .failure(let productServiceError):
                                switch productServiceError {
                                case .failed(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(debugInfo: DebugInfo(message: message, description: description, request: request))
                                case .noInternet(let message, let description, let request):
                                    error = AppCoinsSDKError.networkError(debugInfo: DebugInfo(message: message, description: description, request: request))
                                case .purchaseVerificationFailed(let message, let description, let request):
                                    error = AppCoinsSDKError.unknown(debugInfo: DebugInfo(message: message, description: description, request: request))
                                }
                            }
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        let sortedPurchases = sortPurchasesByCreated(purchases: purchaseList)
                        continuation.resume(returning: sortedPurchases)
                    }
                }
            }
        }
    }
    
    public static func latest(domain: String = (Bundle.main.bundleIdentifier ?? ""), sku: String) async throws -> Purchase? {
        return try await withCheckedThrowingContinuation { continuation in
            
            WalletUseCases.shared.getWalletList { walletList in
                
                let group = DispatchGroup()
                let queue = DispatchQueue(label: "get-latest-purchase-queue", attributes: .concurrent)
                
                var purchaseList : [Purchase] = []
                var error : AppCoinsSDKError? = nil
                
                for wallet in walletList {
                    group.enter()
                    queue.sync {
                        TransactionUseCases.shared.getLatestPurchase(domain: domain, sku: sku, wa: wallet) {
                            result in
                            switch result {
                            case .success(let purchase):
                                if let purchase = purchase { purchaseList.append(purchase) }
                            case .failure(let productServiceError):
                                switch productServiceError {
                                case .failed(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(debugInfo: DebugInfo(message: message, description: description, request: request))
                                case .noInternet(let message, let description, let request):
                                    error = AppCoinsSDKError.networkError(debugInfo: DebugInfo(message: message, description: description, request: request))
                                case .purchaseVerificationFailed(let message, let description, let request):
                                    error = AppCoinsSDKError.unknown(debugInfo: DebugInfo(message: message, description: description, request: request))
                                }
                            }
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        let sortedPurchases = sortPurchasesByCreated(purchases: purchaseList)
                        continuation.resume(returning: sortedPurchases.first)
                    }
                }
            }
        }
    }
    
    // we consider unfinished purchases any purchase that have neither been acknowledged nor consumed
    public static func unfinished(domain: String = (Bundle.main.bundleIdentifier ?? "")) async throws -> [Purchase] {
        return try await withCheckedThrowingContinuation { continuation in
            
            WalletUseCases.shared.getWalletList { walletList in
                
                let group = DispatchGroup()
                let queue = DispatchQueue(label: "get-unfinished-purchases-queue", attributes: .concurrent)
                
                var purchaseList : [Purchase] = []
                var error : AppCoinsSDKError? = nil
                
                for wallet in walletList {
                    group.enter()
                    queue.sync {
                        TransactionUseCases.shared.getPurchasesByState(domain: domain, state: ["PENDING", "ACKNOWLEDGED"], wa: wallet) {
                            result in
                            switch result {
                            case .success(let purchases):
                                purchaseList += purchases
                            case .failure(let productServiceError):
                                switch productServiceError {
                                case .failed(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(debugInfo: DebugInfo(message: message, description: description, request: request))
                                case .noInternet(let message, let description, let request):
                                    error = AppCoinsSDKError.networkError(debugInfo: DebugInfo(message: message, description: description, request: request))
                                case .purchaseVerificationFailed(let message, let description, let request):
                                    error = AppCoinsSDKError.unknown(debugInfo: DebugInfo(message: message, description: description, request: request))
                                }
                            }
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        let sortedPurchases = sortPurchasesByCreated(purchases: purchaseList)
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
    private static var purchaseContinuation: AsyncStream<VerificationResult>.Continuation?
    private static let purchaseStream: AsyncStream<VerificationResult> = {
        AsyncStream { continuation in purchaseContinuation = continuation }
    }()
    
    public static var updates: AsyncStream<VerificationResult> {
        return purchaseStream
    }
    
    internal static func send(_ verificationResult: VerificationResult) {
        purchaseContinuation?.yield(verificationResult)
    }
}
