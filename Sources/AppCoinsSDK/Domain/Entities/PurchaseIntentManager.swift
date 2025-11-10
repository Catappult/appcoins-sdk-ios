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
        Utils.log(
            "PurchaseIntentManager.initialize() at PurchaseIntentManager.swift",
            category: "Lifecycle",
            level: .info
        )
        
        loadFromDisk()
        
        if let current = self.current {
            Utils.log("Sending current Purchase intent at PurchaseIntentManager.swift:initialize")
            Purchase.send(current)
        }
        
        launchTimeoutMonitor()
    }

    internal func set(intent: PurchaseIntent) {
        Utils.log(
            "PurchaseIntentManager.set(intent: \(intent)) at PurchaseIntentManager.swift",
            category: "Lifecycle",
            level: .info
        )
        
        self.current = intent
        Utils.log("Set purchase intent. Saving to disk at PurchaseIntentManager.swift:set")
        
        saveToDisk()
        
        Utils.log("Sending current purchase intent at PurchaseIntentManager.swift:set")
        Purchase.send(intent)
    }
    
    internal func unset() {
        Utils.log(
            "PurchaseIntentManager.unset() at PurchaseIntentManager.swift",
            category: "Lifecycle",
            level: .info
        )
        
        self.current = nil
        Utils.log("Unset purchase intent at PurchaseIntentManager.swift:unset")
        
        Utils.log("Removing purchase intent from disk at PurchaseIntentManager.swift:unset")
        removeFromDisk()
    }

    private func saveToDisk() {
        Utils.log(
            "PurchaseIntentManager.saveToDisk() at PurchaseIntentManager.swift",
            category: "Lifecycle",
            level: .info
        )
        
        if let current = self.current {
            Utils.log("Saving purchase intent at PurchaseIntentManager.swift:saveToDisk")
            SDKUseCases.shared.persistPurchaseIntent(intent: current)
        }
    }

    internal func loadFromDisk() {
        Utils.log(
            "PurchaseIntentManager.loadFromDisk() at PurchaseIntentManager.swift",
            category: "Lifecycle",
            level: .info
        )
        
        guard let storedIntent = SDKUseCases.shared.fetchPurchaseIntent() else {
            Utils.log("There is no stored purchase intent at PurchaseIntentManager.swift:loadFromDisk")
            return
        }
        
        if isIntentExpired(intent: storedIntent) {
            Utils.log("Stored purchase intent is expired. Removing from disk at PurchaseIntentManager.swift:loadFromDisk")
            removeFromDisk()
            
            return
        }
        
        self.current = storedIntent
        Utils.log("Loaded purchase intent at PurchaseIntentManager.swift:loadFromDisk")
    }
    
    private func removeFromDisk() {
        Utils.log(
            "PurchaseIntentManager.removeFromDisk() at PurchaseIntentManager.swift",
            category: "Lifecycle",
            level: .info
        )
        
        Utils.log("Removing purchase intent from disk at PurchaseIntentManager.swift:removeFromDisk")
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
