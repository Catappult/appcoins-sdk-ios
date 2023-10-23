//
//  KeychainHelper.swift
//
//
//  Created by aptoide on 16/05/2023.
//

import Foundation
import os

final internal class KeychainHelper {
    
    static internal let standard = KeychainHelper()
    internal let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")
    
    internal func save<T>(_ item: T, service: String, account: String) throws where T : Codable {
        
        do {
            // Encode as JSON data and save in keychain
            let data = try JSONEncoder().encode(item)
            try save(data, service: service, account: account)
            
        } catch {
            throw KeychainError.error
        }
    }
    
    internal func read<T>(service: String, account: String, type: T.Type) -> T? where T : Codable {
        
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
    
    internal func save(_ data: Data, service: String, account: String) throws {
        
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
    
    internal func read(service: String, account: String) -> Data? {
        
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

    internal func delete(service: String, account: String) {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
        
        // Delete item from keychain
        SecItemDelete(query)
    }
}

internal enum KeychainError: Error {
  case error
}

internal enum PreferencesError: Error {
  case error
}
