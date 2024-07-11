//
//  InMemoryCache.swift
//  App Store iOS
//
//  Created by aptoide on 28/05/2024.
//

import Foundation

internal class InMemoryCache<Key: Hashable & Codable, Value: Codable>: CacheProtocol {
    private let cache = NSCache<WrappedKey<Key>, Entry>()
    
    internal func getValue(forKey key: Key) -> Value? {
        return cache.object(forKey: WrappedKey(key))?.value
    }

    internal func setValue(_ value: Value, forKey key: Key, storageOption: StorageOption) {
        cache.setObject(Entry(value: value), forKey: WrappedKey(key))
    }

    internal func removeValue(forKey key: Key) {
        cache.removeObject(forKey: WrappedKey(key))
    }

    internal func clearCache() {
        cache.removeAllObjects()
    }
    
    private class Entry {
        let value: Value
        
        init(value: Value) {
            self.value = value
        }
    }
    
    internal final class WrappedKey<Key: Hashable & Codable>: NSObject {
        internal let key: Key

        internal init(_ key: Key) { self.key = key }

        override internal var hash: Int { return key.hashValue }

        override internal func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            return value.key == key
        }
    }

}
