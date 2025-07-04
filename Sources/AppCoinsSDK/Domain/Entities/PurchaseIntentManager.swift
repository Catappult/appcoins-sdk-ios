//
//  PurchaseIntentManager.swift
//
//
//  Created by aptoide on 17/04/2025.
//

import Foundation

class PurchaseIntentManager {

    static internal let shared = PurchaseIntentManager()
    
    internal var current: PurchaseIntent?

    private init() {}
    
    internal func initialize() {
        loadFromDisk()
        if let current = self.current { Purchase.send(current) }
        launchTimeoutMonitor()
    }

    internal func set(intent: PurchaseIntent) {
        self.current = intent
        saveToDisk()
        Purchase.send(intent)
    }
    
    internal func unset() {
        self.current = nil
        removeFromDisk()
    }

    private func saveToDisk() {
        if let current = self.current { SDKUseCases.shared.persistPurchaseIntent(intent: current) }
    }

    internal func loadFromDisk() {
        guard let storedIntent = SDKUseCases.shared.fetchPurchaseIntent() else { return }
        
        if isIntentExpired(intent: storedIntent) {
            removeFromDisk()
            return
        }
        
        self.current = storedIntent
    }
    
    private func removeFromDisk() {
        SDKUseCases.shared.removePurchaseIntent()
    }

    private func launchTimeoutMonitor() {
        Task.detached { [weak self] in
            while let self {
                try? await Task.sleep(nanoseconds: 5 * 60 * 1_000_000_000) // 5 minutes
                
                if let current = self.current, isIntentExpired(intent: current) {
                    self.current = nil
                    removeFromDisk()
                }
            }
        }
    }
    
    private func isIntentExpired(intent: PurchaseIntent) -> Bool {
        let timeout: TimeInterval = 30 * 60 // 30 minutes
        
        let now = Date()
        return now.timeIntervalSince(intent.timestamp) > timeout
    }
}
