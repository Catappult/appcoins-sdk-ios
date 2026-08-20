//
//  BrokerUseCases.swift
//

import Foundation

internal class BrokerUseCases {

    internal static let shared: BrokerUseCases = BrokerUseCases()
    private let repository: BrokerRepositoryProtocol

    private init(repository: BrokerRepositoryProtocol = BrokerRepository()) {
        self.repository = repository
    }

    internal func getTransaction(orderId: String, result: @escaping (Result<BrokerTransactionRaw, BrokerError>) -> Void) {
        repository.getTransaction(orderId: orderId, result: result)
    }
}
