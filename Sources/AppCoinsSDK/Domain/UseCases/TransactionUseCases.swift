//
//  TransactionUseCases.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal class TransactionUseCases {
    
    static var shared: TransactionUseCases = TransactionUseCases()
    
    private var repository: TransactionRepositoryProtocol
    
    private init(repository: TransactionRepositoryProtocol = TransactionRepository()) {
        self.repository = repository
    }
    
    internal func getAllPurchases(domain: String, wa: Wallet, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void) {
        repository.getAllPurchases(domain: domain, wa: wa) { result in completion(result) }
    }
    
    internal func getLatestPurchase(domain: String, sku: String, wa: Wallet, completion: @escaping (Result<Purchase?, ProductServiceError>) -> Void) {
        repository.getLatestPurchase(domain: domain, sku: sku, wa: wa) { result in completion(result) }
    }
    
    internal func getPurchasesByState(domain: String, state: [String], wa: Wallet, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void) {
        repository.getPurchasesByState(domain: domain, state: state, wa: wa) { result in completion(result) }
    }
    
    internal func acknowledgePurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.acknowledgePurchase(domain: domain, uid: uid, wa: wa) { result in completion(result) }
    }
    
    internal func consumePurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.consumePurchase(domain: domain, uid: uid, wa: wa) { result in completion(result) }
    }
    
    internal func verifyPurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Purchase, ProductServiceError>) -> Void) {
        repository.verifyPurchase(domain: domain, uid: uid, wa: wa) { result in completion(result) }
    }
}
