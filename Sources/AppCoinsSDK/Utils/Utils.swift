//
//  Utils.swift
//
//
//  Created by aptoide on 03/03/2023.
//

import SwiftUI
@_implementationOnly import os
@_implementationOnly import Security
@_implementationOnly import PPRiskMagnes
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
    
    static internal func transactionResult(result: TransactionResult) {
        NotificationCenter.default.post(name: NSNotification.Name("APPCPurchaseResult"), object: nil, userInfo: ["TransactionResult" : result])
    }

    static internal func getAdyenGatewayAccess() -> String {
        var key : String
        switch BuildConfiguration.environment {
            case .debugSDKDev, .releaseSDKDev:
                key = "387Y3/Tg6eDn+536/vL54+qc7vmc+u/knO3q7emc/pzj//vz+w=="
            case .debugSDKProd, .releaseSDKProd:
                key = "x8LdzvTy7+2d85798urp6P7j5J+c7ujjnpz+/+rl/p3q7f3/ng=="
        }
        
        let obf: UInt8 = 0xAB
                
        let keyData = Data(base64Encoded: key)!
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
    
    static internal func getAppIcon() -> UIImage {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {

            return UIImage(named: lastIcon) ?? UIImage()
        }
        return UIImage()
    }
    
    // Get PayPal Magnes SDK anti-fraud Client Metadata to send with paypal_v2 gateway requests
    static func getMagnesSDKClientMetadataID() -> String {
        let magnesResult: MagnesResult = MagnesSDK.shared().collectAndSubmit()
        return magnesResult.getPayPalClientMetaDataId()
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
