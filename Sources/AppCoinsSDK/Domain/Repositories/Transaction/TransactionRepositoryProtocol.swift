//
//  TransactionRepositoryProtocol.swift
//
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal protocol TransactionRepositoryProtocol {

    func getAllTransactions(domain: String, wa: Wallet, completion: @escaping (Result<[Transaction], ProductServiceError>) -> Void)

    func getLatestTransaction(domain: String, sku: String, wa: Wallet, completion: @escaping (Result<Transaction?, ProductServiceError>) -> Void)

    func getTransactionsByState(domain: String, state: [String], wa: Wallet, completion: @escaping (Result<[Transaction], ProductServiceError>) -> Void)

    func acknowledgeTransaction(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void)

    func consumeTransaction(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void)

    func verifyTransaction(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Transaction, ProductServiceError>) -> Void)
}
