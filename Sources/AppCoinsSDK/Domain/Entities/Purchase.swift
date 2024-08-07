//
//  Purchase.swift
//  
//
//  Created by aptoide on 24/05/2023.
//

import Foundation

public class Purchase: Codable {
    
    public let uid: String
    public let sku: String
    public var state: String
    public let orderUid: String
    public let payload: String?
    public let created: String
    
    internal init(uid: String, sku: String, state: String, orderUid: String, payload: String?, created: String) {
        self.uid = uid
        self.sku = sku
        self.state = state
        self.orderUid = orderUid
        self.payload = payload
        self.created = created
    }
    
    internal init(raw: PurchaseInformationRaw) {
        self.uid = raw.uid
        self.sku = raw.sku
        self.state = raw.state
        self.orderUid = raw.order_uid
        self.payload = raw.payload
        self.created = raw.created
    }
    
    internal static func verify(purchaseUID: String, completion: @escaping (Result<Purchase, AppCoinsSDKError>) -> Void ) {
        let walletUseCases = WalletUseCases.shared
        let transactionUseCases = TransactionUseCases.shared
        let domain = Bundle.main.bundleIdentifier ?? ""
        
        walletUseCases.getWallet() {
            result in
            
            switch result {
            case .success(let wallet):
                transactionUseCases.verifyPurchase(domain: domain, uid: purchaseUID, wa: wallet) {
                    result in
                    
                    switch result {
                    case .success(let purchase):
                        completion(.success(purchase))
                    case .failure(let failure):
                        if failure == .noInternet {
                            completion(.failure(.networkError))
                        } else {
                            completion(.failure(.systemError))
                        }
                    }
                }
            case .failure(let failure):
                if failure == .noInternet {
                    completion(.failure(.networkError))
                } else {
                    completion(.failure(.systemError))
                }
            }
        }
    }
    
    // only accessible internally – the SDK acknowledges the purchase
    internal func acknowledge(completion: @escaping (AppCoinsSDKError?) -> Void) {
        let walletUseCases = WalletUseCases.shared
        let transactionUseCases = TransactionUseCases.shared
        let domain = Bundle.main.bundleIdentifier ?? ""
        
        walletUseCases.getWallet() {
            result in
            
            switch result {
            case .success(let wallet):
                transactionUseCases.acknowledgePurchase(domain: domain, uid: self.uid, wa: wallet) {
                    result in
                    
                    switch result {
                    case .success(_):
                        self.state = "ACKNOWLEDGED"
                        completion(nil)
                    case .failure(let failure):
                        switch failure {
                        case .failed(_):
                            completion(.systemError)
                        case .noInternet:
                            completion(.networkError)
                        default:
                            completion(.systemError)
                        }
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    // accessible by the developer – the app consumes the purchase and attributes the item to the user
    public func finish() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let walletUseCases = WalletUseCases.shared
            let transactionUseCases = TransactionUseCases.shared
            
            walletUseCases.getWalletList() { walletList in
                let domain = Bundle.main.bundleIdentifier ?? ""
                
                let group = DispatchGroup()
                let queue = DispatchQueue(label: "consume-queue", attributes: .concurrent)
                
                var isConsumed = false
                var isNetworkError = false
                
                for wallet in walletList {
                    group.enter()
                    queue.sync {
                        transactionUseCases.consumePurchase(domain: domain, uid: self.uid, wa: wallet) {
                            result in
                            switch result {
                            case .success(_):
                                self.state = "CONSUMED"
                                isConsumed = true
                            case .failure(let failure):
                                switch failure {
                                case .noInternet: isNetworkError = true
                                default: break
                                }
                            }
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    if isConsumed { continuation.resume() }
                    else if isNetworkError { continuation.resume(throwing: AppCoinsSDKError.networkError) }
                    else { continuation.resume(throwing: AppCoinsSDKError.unknown) }
                }
            }
        }
    }
    
    // get all the user's purchases
    public static func all() async throws -> [Purchase] {
        return try await withCheckedThrowingContinuation { continuation in
            let walletUseCases = WalletUseCases.shared
            let transactionUseCases = TransactionUseCases.shared
            
            walletUseCases.getWalletList() { walletList in
                let domain = Bundle.main.bundleIdentifier ?? ""
                
                let group = DispatchGroup()
                let queue = DispatchQueue(label: "get-all-purchases-queue", attributes: .concurrent)
                
                var purchaseList : [Purchase] = []
                var error : AppCoinsSDKError? = nil
                
                for wallet in walletList {
                    group.enter()
                    queue.sync {
                        transactionUseCases.getAllPurchases(domain: domain, wa: wallet) {
                            result in
                            
                            switch result {
                            case .success(let purchases):
                                purchaseList += purchases
                            case .failure(let failure):
                                if failure == .failed { error = .systemError }
                                else if failure == .noInternet { error = .networkError }
                                else { error = .unknown }
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
    
    public static func latest(sku: String) async throws -> Purchase? {
        return try await withCheckedThrowingContinuation { continuation in
            let walletUseCases = WalletUseCases.shared
            let transactionUseCases = TransactionUseCases.shared
            
            walletUseCases.getWalletList { walletList in
                let domain = Bundle.main.bundleIdentifier ?? ""
                
                let group = DispatchGroup()
                let queue = DispatchQueue(label: "get-latest-purchase-queue", attributes: .concurrent)
                
                var purchaseList : [Purchase] = []
                var error : AppCoinsSDKError? = nil
                
                for wallet in walletList {
                    group.enter()
                    queue.sync {
                        transactionUseCases.getLatestPurchase(domain: domain, sku: sku, wa: wallet) {
                            result in
                            switch result {
                            case .success(let purchase):
                                if let purchase = purchase { purchaseList.append(purchase) }
                            case .failure(let failure):
                                if failure == .failed { error = .systemError }
                                else if failure == .noInternet { error = .networkError }
                                else { error = .unknown }
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
    public static func unfinished() async throws -> [Purchase] {
        return try await withCheckedThrowingContinuation { continuation in
            let walletUseCases = WalletUseCases.shared
            let transactionUseCases = TransactionUseCases.shared
            
            walletUseCases.getWalletList { walletList in
                let domain = Bundle.main.bundleIdentifier ?? ""
                
                let group = DispatchGroup()
                let queue = DispatchQueue(label: "get-unfinished-purchases-queue", attributes: .concurrent)
                
                var purchaseList : [Purchase] = []
                var error : AppCoinsSDKError? = nil
                
                for wallet in walletList {
                    group.enter()
                    queue.sync {
                        transactionUseCases.getPurchasesByState(domain: domain, state: "PENDING", wa: wallet) {
                            result in
                            switch result {
                            case .success(let purchases):
                                purchaseList += purchases
                            case .failure(let failure):
                                if failure == .failed { error = .systemError }
                                else if failure == .noInternet { error = .networkError }
                                else { error = .unknown }
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
}
