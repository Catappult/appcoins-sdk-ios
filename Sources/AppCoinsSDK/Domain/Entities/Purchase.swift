//
//  File.swift
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
    public let payload: String
    public let created: String
    
    init(uid: String, sku: String, state: String, orderUid: String, payload: String, created: String) {
        self.uid = uid
        self.sku = sku
        self.state = state
        self.orderUid = orderUid
        self.payload = payload
        self.created = created
    }
    
    init(raw: PurchaseInformationRaw) {
        self.uid = raw.uid
        self.sku = raw.sku
        self.state = raw.state
        self.orderUid = raw.order_uid
        self.payload = raw.payload
        self.created = raw.created
    }
    
    static func verify(purchaseUID: String, completion: @escaping (Result<Purchase, AppCoinsSDKError>) -> Void ) {
        let walletUseCases = WalletUseCases.shared
        let transactionUseCases = TransactionUseCases.shared
        let domain = Bundle.main.bundleIdentifier ?? ""
        
        if let wallet = walletUseCases.getClientWallet(), let wa = wallet.address {
            let waSignature = wallet.getSignedWalletAddress()
            transactionUseCases.verifyPurchase(domain: domain, uid: purchaseUID, wa: wa, waSignature: waSignature) {
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
        }
    }
    
    // only accessible internally – the SDK acknowledges the purchase
    func acknowledge(completion: @escaping (AppCoinsSDKError?) -> Void) {
        let walletUseCases = WalletUseCases.shared
        let transactionUseCases = TransactionUseCases.shared
        let domain = Bundle.main.bundleIdentifier ?? ""
        
        if let wallet = walletUseCases.getClientWallet(), let wa = wallet.address {
            let waSignature = wallet.getSignedWalletAddress()
            transactionUseCases.acknowledgePurchase(domain: domain, uid: self.uid, wa: wa, waSignature: waSignature) {
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
        }
    }
    
    // accessible by the developer – the app consumes the purchase and attributes the item to the user
    public func consume(completion: @escaping (AppCoinsSDKError?) -> Void) {
        let walletUseCases = WalletUseCases.shared
        let transactionUseCases = TransactionUseCases.shared
        
        if let wallet = walletUseCases.getClientWallet(), let wa = wallet.address {
            let waSignature = wallet.getSignedWalletAddress()
            
            let domain = Bundle.main.bundleIdentifier ?? ""
            transactionUseCases.consumePurchase(domain: domain, uid: self.uid, wa: wa, waSignature: waSignature) {
                result in
                switch result {
                case .success(_):
                    self.state = "CONSUMED"
                    completion(nil)
                case .failure(let failure):
                    switch failure {
                    case .failed(_):
                        completion(.unknown)
                    case .noInternet:
                        completion(.networkError)
                    default:
                        completion(.unknown)
                    }
                }
            }
        }
    }
    
    // get all the user's purchases
    public static func all(completion: @escaping (Result<[Purchase], AppCoinsSDKError>) -> Void) {
        let walletUseCases = WalletUseCases.shared
        let transactionUseCases = TransactionUseCases.shared
        
        if let wallet = walletUseCases.getClientWallet(), let wa = wallet.address {
            let waSignature = wallet.getSignedWalletAddress()
            let domain = Bundle.main.bundleIdentifier ?? ""
            transactionUseCases.getAllPurchases(domain: domain, wa: wa, waSignature: waSignature) {
                result in
                switch result {
                case .success(let purchases):
                    completion(.success(purchases))
                case .failure(let failure):
                    if failure == .failed { completion(.failure(.systemError)) }
                    else if failure == .noInternet { completion(.failure(.networkError)) }
                    else { completion(.failure(.unknown)) }
                }
            }
        }
    }
    
    public static func latest(sku: String, completion: @escaping (Result<Purchase?, AppCoinsSDKError>) -> Void) {
        let walletUseCases = WalletUseCases.shared
        let transactionUseCases = TransactionUseCases.shared
        
        if let wallet = walletUseCases.getClientWallet(), let wa = wallet.address {
            let waSignature = wallet.getSignedWalletAddress()
            let domain = Bundle.main.bundleIdentifier ?? ""
            transactionUseCases.getLatestPurchase(domain: domain, sku: sku, wa: wa, waSignature: waSignature) {
                result in
                switch result {
                case .success(let purchase):
                    completion(.success(purchase))
                case .failure(let failure):
                    if failure == .failed { completion(.failure(.systemError)) }
                    else if failure == .noInternet { completion(.failure(.networkError)) }
                    else { completion(.failure(.unknown)) }
                }
            }
        }
    }
    
    // we consider unfinished purchases any purchase that have neither been acknowledged nor consumed
    public static func unfinished(completion: @escaping (Result<[Purchase], AppCoinsSDKError>) -> Void) {
        let walletUseCases = WalletUseCases.shared
        let transactionUseCases = TransactionUseCases.shared
        
        if let wallet = walletUseCases.getClientWallet(), let wa = wallet.address {
            let waSignature = wallet.getSignedWalletAddress()
            let domain = Bundle.main.bundleIdentifier ?? ""
            transactionUseCases.getPurchasesByState(domain: domain, state: "PENDING", wa: wa, waSignature: waSignature) {
                result in
                switch result {
                case .success(let purchases):
                    completion(.success(purchases))
                case .failure(let failure):
                    if failure == .failed { completion(.failure(.systemError)) }
                    else if failure == .noInternet { completion(.failure(.networkError)) }
                    else { completion(.failure(.unknown)) }
                }
            }
        }
    }
}
