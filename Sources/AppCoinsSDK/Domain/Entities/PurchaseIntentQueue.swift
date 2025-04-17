//
//  PurchaseIntentQueue.swift
//
//
//  Created by aptoide on 17/04/2025.
//

import Foundation

struct PurchaseIntentQueue {

    static internal let shared = PurchaseIntentQueue()
    
    internal let queue: [PurchaseIntent]

    private init() {
        loadFromDisk()
        queue.forEach { Purchase.send($0) }
        launchTimeoutMonitor()
    }

    internal func enqueue(_ intent: PurchaseIntent) {
        storage[purchase.id] = purchase
        continuation?.yield(purchase)
        saveToDisk()
    }

    /// Update an already‑stored element (used by `approve()`).
    func persist(_ purchase: inout PendingIndirectPurchase) {
        storage[purchase.id] = purchase
        saveToDisk()
    }

    /// Remove when finished *or* rejected.
    func finish(id: UUID, keep: Bool = false) {
        if keep == false { storage[id] = nil }
        saveToDisk()
    }

    // Make the public stream easily accessible
    static var pending: AsyncStream<PendingIndirectPurchase> { shared.stream }

    // MARK: –– Persistence helpers

    private let fileURL: URL = {
        FileManager.default.urls(for: .applicationSupportDirectory,
                                 in: .userDomainMask)[0]
            .appendingPathComponent("IndirectPurchaseQueue.json")
    }()

    private func saveToDisk() {
        guard let data = try? JSONEncoder().encode(storage.values) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func loadFromDisk() {
        guard let data = try? Data(contentsOf: fileURL),
              let array = try? JSONDecoder().decode([PendingIndirectPurchase].self,
                                                    from: data) else { return }
        storage = Dictionary(uniqueKeysWithValues: array.map { ($0.id, $0) })
    }

    // MARK: –– Timeout auto‑reject (optional but recommended)
    private func launchTimeoutMonitor() {
        Task.detached { [weak self] in
            while let self {
                try? await Task.sleep(for: .minutes(5))
                await self.autoRejectIfNeeded(timeout: 15 * 60)   // 15 min
            }
        }
    }

    private func autoRejectIfNeeded(timeout: TimeInterval) {
        let now = Date()
        for var purchase in storage.values where purchase.state == .pending {
            guard let created = purchase.id.timestampDate,
                  now.timeIntervalSince(created) > timeout else { continue }

            Task { await purchase.reject(reason: .timeout) }      // async context
        }
    }
}
