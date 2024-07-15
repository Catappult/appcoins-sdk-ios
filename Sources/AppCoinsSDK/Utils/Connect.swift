//
//  Connect.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation
import CommonCrypto

internal class Connect {
    
    private let key = "IaY8iJ0amBu1hc68cmQMlS9W"
    private let type = "mrm0EaNLza04b7cz"
    static let shared: Connect = Connect()
    
    private init() {}
    
    internal func getConnection(environment: String) -> String? {
        guard let decrypted = decrypt(key: environment) else {
            return nil
        }
        return deobfuscate(key: decrypted)
    }
    
    private func deobfuscate(key: String) -> String? {
        guard let data = Data(base64Encoded: key) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
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
            key, kCCKeySizeAES256,
            type,
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
