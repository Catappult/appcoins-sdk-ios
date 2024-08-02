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
    private let mmpRepository: MMPRepositoryProtocol
    
    private init(repository: PayFlowRepositoryProtocol = PayFlowRepository(), mmpRepository: MMPRepositoryProtocol = MMPRepository()) {
        self.repository = repository
        self.mmpRepository = mmpRepository
    }
    
    internal func setPayFlow() { repository.setPayFlow(oemID: mmpRepository.getOEMID()) }
    
    internal func getPayFlow() -> PayFlowType { return repository.getPayFlow() }
}
