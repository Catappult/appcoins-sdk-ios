//
//  KeychainHelper.swift
//  appcoins-wallet-ios
//
//  Created by aptoide on 16/05/2023.
//  Copyright © 2023 Tiago Teodoro. All rights reserved.
//

import Foundation
import os

final class KeychainHelper {
    
    static let standard = KeychainHelper()
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")
    
    func save<T>(_ item: T, service: String, account: String) throws where T : Codable {
        
        do {
            // Encode as JSON data and save in keychain
            let data = try JSONEncoder().encode(item)
            try save(data, service: service, account: account)
            
        } catch {
            throw KeychainError.error
        }
    }
    
    func read<T>(service: String, account: String, type: T.Type) -> T? where T : Codable {
        
        // Read item data from keychain
        guard let data = read(service: service, account: account) else {
            return nil
        }
        
        // Decode JSON data to object
        do {
            let item = try JSONDecoder().decode(type, from: data)
            return item
        } catch {
            assertionFailure("Fail to decode item for keychain: \(error)")
            return nil
        }
    }
    
    func save(_ data: Data, service: String, account: String) throws {
        
        // Create query
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ] as CFDictionary
        
        // Add data in query to keychain
        let status = SecItemAdd(query, nil)
        
        if status == errSecDuplicateItem {
                // Item already exist, thus update it.
                let query = [
                    kSecAttrService: service,
                    kSecAttrAccount: account,
                    kSecClass: kSecClassGenericPassword,
                ] as CFDictionary

                let attributesToUpdate = [kSecValueData: data] as CFDictionary

                // Update existing item
                SecItemUpdate(query, attributesToUpdate)
        }
        
        logger.error("\(status, privacy: .public)")
        if status != errSecSuccess && status != errSecDuplicateItem {
            logger.error("\("2\(status)", privacy: .public)")
            throw KeychainError.error
        }
        
    }
    
    func read(service: String, account: String) -> Data? {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return (result as? Data)
    }

    func delete(service: String, account: String) {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
        
        // Delete item from keychain
        SecItemDelete(query)
    }
}

enum KeychainError: Error {
  case error
}

enum PreferencesError: Error {
  case error
}
