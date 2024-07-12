//
//  Cache.swift
//  App Store iOS
//
//  Created by aptoide on 28/05/2024.
//

import Foundation

internal class Cache<Key: Hashable & Codable, Value: Codable>: CacheProtocol {
    private let memoryCache: InMemoryCache<Key, Value>
    private let diskCache: DiskCache<Key, Value>

    internal init(cacheName: String) {
        self.memoryCache = InMemoryCache<Key, Value>()
        self.diskCache = DiskCache<Key, Value>(cacheName: cacheName)
    }
    
    internal func getValue(forKey key: Key) -> Value? {
        if let value = memoryCache.getValue(forKey: key) {
            return value
        }
        if let value = diskCache.getValue(forKey: key) {
            memoryCache.setValue(value, forKey: key, storageOption: .memory) // Load into memory for faster access next time
            return value
        }
        return nil
    }
    
    internal func setValue(_ value: Value, forKey key: Key, storageOption: StorageOption) {
        switch storageOption {
        case .memory:
            memoryCache.setValue(value, forKey: key, storageOption: storageOption)
        case .disk(let ttl):
            memoryCache.setValue(value, forKey: key, storageOption: .memory)
            diskCache.setValue(value, forKey: key, storageOption: .disk(ttl: ttl))
        }
    }
    
    internal func removeValue(forKey key: Key) {
        memoryCache.removeValue(forKey: key)
        diskCache.removeValue(forKey: key)
    }
    
    internal func clearCache() {
        memoryCache.clearCache()
        diskCache.clearCache()
    }
}

