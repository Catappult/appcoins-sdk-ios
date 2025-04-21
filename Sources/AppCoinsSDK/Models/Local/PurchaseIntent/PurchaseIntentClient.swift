//
//  PurchaseIntentClient.swift
//
//
//  Created by aptoide on 17/04/2025.
//

import Foundation

internal class PurchaseIntentClient: PurchaseIntentService {
    
    private let filename: String = "PurchaseIntent.json"
    
    internal func persist(intent: PurchaseIntent) {
        print("[AppCoinsSDK] Persisting intent: \(intent)")
        guard let data = try? JSONEncoder().encode(intent) else { return }
        Utils.writeToFile(filename: filename, content: data)
    }
    
    internal func fetch() -> PurchaseIntent? {
        guard let data = Utils.readFromFile(filename: filename) else { return nil }
        return try? JSONDecoder().decode(PurchaseIntent.self, from: data)
    }
    
    internal func remove() {
        Utils.deleteFile(filename: filename)
    }

}
