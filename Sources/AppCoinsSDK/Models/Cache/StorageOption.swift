//
//  StorageOption.swift
//  App Store iOS
//
//  Created by aptoide on 28/05/2024.
//

import Foundation

internal enum StorageOption {
    case memory
    case disk(ttl: TimeInterval)
}
