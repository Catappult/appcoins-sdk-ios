//
//  BrokerRepositoryProtocol.swift
//

import Foundation

internal protocol BrokerRepositoryProtocol {
    func getTransaction(orderId: String, result: @escaping (Result<BrokerTransactionRaw, BrokerError>) -> Void)
}
