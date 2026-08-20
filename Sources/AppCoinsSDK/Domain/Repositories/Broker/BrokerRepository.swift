//
//  BrokerRepository.swift
//

import Foundation

internal class BrokerRepository: BrokerRepositoryProtocol {

    private let brokerService: BrokerService = BrokerClient()

    internal func getTransaction(orderId: String, result: @escaping (Result<BrokerTransactionRaw, BrokerError>) -> Void) {
        brokerService.getTransaction(orderId: orderId, result: result)
    }
}
