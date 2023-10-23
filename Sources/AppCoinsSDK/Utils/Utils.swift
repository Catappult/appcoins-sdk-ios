//
//  Utils.swift
//
//
//  Created by aptoide on 03/03/2023.
//

import SwiftUI
import os
import Security

internal struct Utils {
    
    static internal let bottomSafeAreaHeight: CGFloat = UIApplication.shared.windows[0].safeAreaInsets.bottom
 
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
        if !didSave { print("ERROR") } // TODO couldn't save
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
    
    static internal func log(message: String) {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")
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
    
    static internal func transactionResult(result: TransactionResult) {
        NotificationCenter.default.post(name: NSNotification.Name("APPCPurchaseResult"), object: nil, userInfo: ["TransactionResult" : result])
    }

    static internal func getAdyenGatewayAccess() -> String {
        let obf: UInt8 = 0xAB
        let keyData = Data(base64Encoded: "387Y3/Tg6eDn+536/vL54+qc7vmc+u/knO3q7emc/pzj//vz+w==")!
        var deobf = Data()

        for byte in keyData {
            deobf.append(byte ^ obf)
        }

        return String(data: deobf, encoding: .utf8) ?? ""
    }
    
    static internal func getCountryCode() -> String? {
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            return countryCode
        } else { return nil }
    }
    
    static internal func isWalletInstalled() -> Bool {
        return UIApplication.shared.canOpenURL((URL(string: "com.aptoide.appcoins-wallet://"))!)
    }
    
    static internal func getAppIcon() -> UIImage {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {

            return UIImage(named: lastIcon) ?? UIImage()
        }
        return UIImage()
    }
}
