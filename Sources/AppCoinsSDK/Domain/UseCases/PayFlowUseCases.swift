//
//  PayFlowUseCases.swift
//
//
//  Created by Graciano Caldeira on 25/07/2024.
//

import Foundation

internal class PayFlowUseCases {
    
    internal static let shared: PayFlowUseCases = PayFlowUseCases()
    private let repository: PayFlowRepositoryProtocol
    
    private init(repository: PayFlowRepositoryProtocol = PayFlowRepository()) {
        self.repository = repository
    }
    
    internal func setPayFlow() { repository.setPayFlow() }
    
    internal func getPayFlow() -> PayFlowType { return repository.getPayFlow() }
}
