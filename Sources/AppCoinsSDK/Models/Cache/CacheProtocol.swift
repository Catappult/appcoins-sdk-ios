//
//  CacheProtocol.swift
//  App Store iOS
//
//  Created by aptoide on 28/05/2024.
//

import Foundation

internal protocol CacheProtocol {
    associatedtype Key: Hashable
    associatedtype Value
    
    func getValue(forKey key: Key) -> Value?
    func setValue(_ value: Value, forKey key: Key, storageOption: StorageOption)
    func removeValue(forKey key: Key)
    func clearCache()
}
