//
//  Maze.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation
import CommonCrypto

internal class Maze {
    
    private let token = "IaY8iJ0amBu1hc68cmQMlS9W"
    private let type = "mrm0EaNLza04b7cz"
    static let shared: Maze = Maze()
    
    private init() {}
    
    internal func get(key: [UInt8]) -> String? {
        if let encodedString = String(bytes: key, encoding: .utf8) {
            guard let data = Data(base64Encoded: encodedString) else { return nil }
            var buffer = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
            var numBytesDecrypted: size_t = 0
            let cryptStatus = CCCrypt(
                CCOperation(kCCDecrypt),
                CCAlgorithm(kCCAlgorithmAES128),
                CCOptions(kCCOptionPKCS7Padding),
                token, kCCKeySizeAES256,
                type,
                (data as NSData).bytes, data.count,
                &buffer, buffer.count,
                &numBytesDecrypted
            )
            if cryptStatus == kCCSuccess {
                let data = Data(bytes: buffer, count: numBytesDecrypted)
                guard let newData = Data(base64Encoded: data) else { return nil }
                return String(data: newData, encoding: .utf8)
            } else {
                return nil
            }
        } else {
            print("Failed!")
            return nil
        }
    }
}
