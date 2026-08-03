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

    internal func getAllTransactions(domain: String, wa: Wallet, completion: @escaping (Result<[Transaction], ProductServiceError>) -> Void) {
        repository.getAllTransactions(domain: domain, wa: wa) { result in completion(result) }
    }

    internal func getLatestTransaction(domain: String, sku: String, wa: Wallet, completion: @escaping (Result<Transaction?, ProductServiceError>) -> Void) {
        repository.getLatestTransaction(domain: domain, sku: sku, wa: wa) { result in completion(result) }
    }

    internal func getTransactionsByState(domain: String, state: [String], wa: Wallet, completion: @escaping (Result<[Transaction], ProductServiceError>) -> Void) {
        repository.getTransactionsByState(domain: domain, state: state, wa: wa) { result in completion(result) }
    }

    internal func acknowledgeTransaction(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.acknowledgeTransaction(domain: domain, uid: uid, wa: wa) { result in completion(result) }
    }

    internal func consumeTransaction(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.consumeTransaction(domain: domain, uid: uid, wa: wa) { result in completion(result) }
    }

    internal func verifyTransaction(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Transaction, ProductServiceError>) -> Void) {
        repository.verifyTransaction(domain: domain, uid: uid, wa: wa) { result in completion(result) }
    }
}
