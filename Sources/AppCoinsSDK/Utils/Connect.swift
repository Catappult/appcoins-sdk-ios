//
//  Connect.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation
import CommonCrypto

internal class Connect {
    
    private let obfusc = "IaY8iJ0amBu1hc68cmQMlS9W"
    private let obfuscType = "mrm0EaNLza04b7cz"
    static let shared: Connect = Connect()
    
    private init() {}
    
//    // Function to set (store) the obfuscated and encrypted key
//    internal func set() -> String {
//        switch BuildConfiguration.environment {
//        case .debugSDKDev, .releaseSDKDev:
//            return encrypt(key: obfuscate(key: "305bdd41-271f-4618-a1ea-0793da9e04ef"))
//        case .debugSDKProd, .releaseSDKProd:
//            return encrypt(key: obfuscate(key: "305bdd41-271f-4618-a1ea-0793da9e04ef"))
//        }
//    }
    
    // Function to get (retrieve) the original key from the obfuscated and encrypted key
    internal func get(environment: String) -> String? {
//        
//        var env = ""
//        switch BuildConfiguration.environment {
//        case .debugSDKDev, .releaseSDKDev:
//            env = dev
//        case .debugSDKProd, .releaseSDKProd:
//            env = prod
//        }
        
        guard let decrypted = decrypt(key: environment) else {
            return nil
        }
        return deobfuscate(key: decrypted)
    }
    
    // Obfuscate the key (example using base64 encoding)
    private func obfuscate(key: String) -> String {
        let data = key.data(using: .utf8)!
        return data.base64EncodedString()
    }
    
    // Deobfuscate the key
    private func deobfuscate(key: String) -> String? {
        guard let data = Data(base64Encoded: key) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    // Encrypt the obfuscated key
    private func encrypt(key: String) -> String {
        let data = key.data(using: .utf8)!
        var buffer = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
        var numBytesEncrypted: size_t = 0
        let cryptStatus = CCCrypt(
            CCOperation(kCCEncrypt),
            CCAlgorithm(kCCAlgorithmAES128),
            CCOptions(kCCOptionPKCS7Padding),
            obfusc, kCCKeySizeAES256,
            obfuscType,
            (data as NSData).bytes, data.count,
            &buffer, buffer.count,
            &numBytesEncrypted
        )
        if cryptStatus == kCCSuccess {
            let encryptedData = Data(bytes: buffer, count: numBytesEncrypted)
            return encryptedData.base64EncodedString()
        } else {
            return ""
        }
    }
    
    // Decrypt the obfuscated key
    private func decrypt(key: String) -> String? {
        guard let data = Data(base64Encoded: key) else {
            return nil
        }
        var buffer = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
        var numBytesDecrypted: size_t = 0
        let cryptStatus = CCCrypt(
            CCOperation(kCCDecrypt),
            CCAlgorithm(kCCAlgorithmAES128),
            CCOptions(kCCOptionPKCS7Padding),
            obfusc, kCCKeySizeAES256,
            obfuscType,
            (data as NSData).bytes, data.count,
            &buffer, buffer.count,
            &numBytesDecrypted
        )
        if cryptStatus == kCCSuccess {
            let decryptedData = Data(bytes: buffer, count: numBytesDecrypted)
            return String(data: decryptedData, encoding: .utf8)
        } else {
            return nil
        }
    }
}
