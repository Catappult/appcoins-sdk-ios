//
//  InMemoryCache.swift
//  App Store iOS
//
//  Created by aptoide on 28/05/2024.
//

import Foundation

class InMemoryCache<Key: Hashable & Codable, Value: Codable>: CacheProtocol {
    private let cache = NSCache<WrappedKey<Key>, Entry>()
    
    func getValue(forKey key: Key) -> Value? {
        return cache.object(forKey: WrappedKey(key))?.value
    }

    func setValue(_ value: Value, forKey key: Key, storageOption: StorageOption) {
        cache.setObject(Entry(value: value), forKey: WrappedKey(key))
    }

    func removeValue(forKey key: Key) {
        cache.removeObject(forKey: WrappedKey(key))
    }

    func clearCache() {
        cache.removeAllObjects()
    }
    
    private class Entry {
        let value: Value
        
        init(value: Value) {
            self.value = value
        }
    }
    
    final class WrappedKey<Key: Hashable & Codable>: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            return value.key == key
        }
    }

}
