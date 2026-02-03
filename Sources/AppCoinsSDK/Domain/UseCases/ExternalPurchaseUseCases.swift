//
//  ExternalPurchaseUseCases.swift
//  AppCoinsSDK
//
//  Created by aptoide on 24/12/2025.
//

import Foundation
@_implementationOnly import SwiftData

@available(iOS 26, *)
internal class ExternalPurchaseUseCases {
    
    static let shared = ExternalPurchaseUseCases()
    internal var repository: ExternalPurchaseServiceRepositoryProtocol?
    
    private lazy var modelContainer: ModelContainer? = {
        let schema = Schema([ExternalPurchaseTokenModel.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try? ModelContainer(for: schema, configurations: [configuration])
    }()
    
    private init() {
        // Lazy initialize repository when modelContainer is available
        if let container = modelContainer {
            let context = ModelContext(container)
            self.repository = ExternalPurchaseServiceRepository(context: context)
        }
    }
    
    internal func reportToken() {
        repository?.reportToken()
    }
    
    internal func associateTransaction(transactionUID: String) {
        repository?.associateTransaction(transactionUID: transactionUID)
    }
    
    internal func flushReports() {
        repository?.flushReports()
    }
    
}
