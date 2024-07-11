//
//  DiskCache.swift
//  App Store iOS
//
//  Created by aptoide on 28/05/2024.
//

import Foundation

internal class DiskCache<Key: Hashable & Codable, Value: Codable>: CacheProtocol {
    private let fileManager = FileManager.default
    private let fileURL: URL
    
    init(cacheName: String) {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        fileURL = urls[0].appendingPathComponent(cacheName).appendingPathExtension("cache")
    }
    
    private func loadCache() -> [Key: Entry]? {
        guard let data = try? Data(contentsOf: fileURL),
              let cache = try? JSONDecoder().decode([Key: Entry].self, from: data) else {
            return nil
        }
        return cache
    }
    
    private func saveCache(_ cache: [Key: Entry]) {
        if let data = try? JSONEncoder().encode(cache) {
            try? data.write(to: fileURL)
        }
    }
    
    internal func getValue(forKey key: Key) -> Value? {
        guard var cache = loadCache() else {
            return nil
        }
        
        if let entry = cache[key], Date() <= entry.expirationDate {
            return entry.value
        } else {
            cache.removeValue(forKey: key)
            saveCache(cache)
            return nil
        }
    }
    
    internal func setValue(_ value: Value, forKey key: Key, storageOption: StorageOption) {
        var ttl: TimeInterval
        switch storageOption {
        case .memory:
            return
        case .disk(let disk_ttl):
            ttl = disk_ttl
        }
        var cache = loadCache() ?? [:]
        let expirationDate = Date().addingTimeInterval(ttl)
        cache[key] = Entry(value: value, expirationDate: expirationDate)
        saveCache(cache)
    }
    
    internal func removeValue(forKey key: Key) {
        guard var cache = loadCache() else {
            return
        }
        cache.removeValue(forKey: key)
        saveCache(cache)
    }
    
    internal func clearCache() {
        try? fileManager.removeItem(at: fileURL)
    }
    
    private struct Entry: Codable {
        let value: Value
        let expirationDate: Date
    }
}
