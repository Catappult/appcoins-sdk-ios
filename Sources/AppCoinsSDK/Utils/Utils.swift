//
//  Utils.swift
//  appcoins-sdk
//
//  Created by aptoide on 03/03/2023.
//

import SwiftUI
import os
import Security

struct Utils {
    
    static let bottomSafeAreaHeight: CGFloat = UIApplication.shared.windows[0].safeAreaInsets.bottom
 
    static func writeToPreferences(key: String, value: String?) throws -> Void {
        let preferences = UserDefaults.standard
        if value != nil { preferences.setValue(value, forKey: key) } else { preferences.removeObject(forKey: key) }
        
        // Save to disk
        let didSave = preferences.synchronize()
        if !didSave { throw PreferencesError.error }
    }

    static func deleteFromPreferences(key: String) -> Void {
        let preferences = UserDefaults.standard
        preferences.removeObject(forKey: key)
        
        // Save to disk
        let didSave = preferences.synchronize()
        if !didSave { print("ERROR") } // TODO couldn't save
    }
    
    static func readFromPreferences(key: String) -> String {
        let preferences = UserDefaults.standard
        return preferences.string(forKey: key) ?? ""
    }
    
    static func writeToKeychain(key: String, value: String) throws -> Void {
        try KeychainHelper().save(value, service: key, account: "com.aptoide.appcoins-wallet")
    }

    static func deleteFromKeychain(key: String) -> Void {
        KeychainHelper().delete(service: key, account: "com.aptoide.appcoins-wallet")
    }

    static func readFromKeychain(key: String) -> String? {
        return KeychainHelper().read(service: key, account: "com.aptoide.appcoins-wallet", type: String.self) ?? nil
    }
    
    static func log(message: String) {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")
        logger.error("\(message, privacy: .public)")
    }
    
    static func generateRandomPassword() -> String {
        let passwordCharacters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
        let len = 24
        var password = ""
        for _ in 0..<len {
            let rand = arc4random_uniform(UInt32(passwordCharacters.count))
            password.append(passwordCharacters[Int(rand)])
        }
        return password
    }
    
    static func generatePrivateKey() -> Data {
        // Generate a random 32-byte private key
        let privateKey = Data(count: 32).map { _ in UInt8.random(in: 0...255) }
        return Data(privateKey)
    }
    
    static func transactionResult(result: TransactionResult) {
        NotificationCenter.default.post(name: NSNotification.Name("APPCPurchaseResult"), object: nil, userInfo: ["TransactionResult" : result])
    }

    static func getAdyenGatewayAccess() -> String {
        let obf: UInt8 = 0xAB
        let keyData = Data(base64Encoded: "387Y3/Tg6eDn+536/vL54+qc7vmc+u/knO3q7emc/pzj//vz+w==")!
        var deobf = Data()

        for byte in keyData {
            deobf.append(byte ^ obf)
        }

        return String(data: deobf, encoding: .utf8) ?? ""
    }
    
    static func getCountryCode() -> String? {
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            return countryCode
        } else { return nil }
    }
}
