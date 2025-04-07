//
//  Utils.swift
//
//
//  Created by aptoide on 03/03/2023.
//

import SwiftUI
@_implementationOnly import os
@_implementationOnly import Security
@_implementationOnly import CommonCrypto

internal struct Utils {
    
    static internal let bottomSafeAreaHeight: CGFloat = UIApplication.shared.windows[0].safeAreaInsets.bottom
    static internal let topSafeAreaHeight: CGFloat = UIApplication.shared.windows[0].safeAreaInsets.top
    
    static internal func writeToPreferences(key: String, value: String?) throws -> Void {
        let preferences = UserDefaults.standard
        if value != nil { preferences.setValue(value, forKey: key) } else { preferences.removeObject(forKey: key) }
        
        // Save to disk
        let didSave = preferences.synchronize()
        if !didSave { throw PreferencesError.error }
    }
    
    static internal func deleteFromPreferences(key: String) -> Void {
        let preferences = UserDefaults.standard
        preferences.removeObject(forKey: key)
        
        // Save to disk
        let didSave = preferences.synchronize()
    }
    
    static internal func readFromPreferences(key: String) -> String {
        let preferences = UserDefaults.standard
        return preferences.string(forKey: key) ?? ""
    }
    
    static internal func writeToKeychain(key: String, value: String) throws -> Void {
        try KeychainHelper().save(value, service: key, account: "com.aptoide.appcoins-wallet")
    }
    
    static internal func deleteFromKeychain(key: String) -> Void {
        KeychainHelper().delete(service: key, account: "com.aptoide.appcoins-wallet")
    }
    
    static internal func readFromKeychain(key: String) -> String? {
        return KeychainHelper().read(service: key, account: "com.aptoide.appcoins-wallet", type: String.self) ?? nil
    }
    
    static func log(_ message: String, category: String = "Debug") {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: category)
        let message = "[AppCoinsSDK] \(message)"
        logger.error("\(message, privacy: .public)")
    }
    
    static internal func generateRandomPassword() -> String {
        let passwordCharacters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
        let len = 24
        var password = ""
        for _ in 0..<len {
            let rand = arc4random_uniform(UInt32(passwordCharacters.count))
            password.append(passwordCharacters[Int(rand)])
        }
        return password
    }
    
    static internal func generatePrivateKey() -> Data {
        // Generate a random 32-byte private key
        let privateKey = Data(count: 32).map { _ in UInt8.random(in: 0...255) }
        return Data(privateKey)
    }
    
    static func md5(_ string: String) -> String {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes { digestBytes in
            messageData.withUnsafeBytes { messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}
