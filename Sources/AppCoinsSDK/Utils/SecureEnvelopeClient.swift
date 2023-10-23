//
//  SecureEnvelopeClient.swift
//
//
//  Created by aptoide on 28/09/2023.
//

import Foundation
import CryptoKit
import Security

internal class SecureEnvelopeClient {
    internal var publicKey: SecKey?
    private var privateKey: SecKey?
    
    static internal var shared = SecureEnvelopeClient()

    internal init() {
        generateAsymmetricKeys()
    }
    
    // Generate a pair of asymmetric keys
    private func generateAsymmetricKeys() {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048, // Adjust key size as needed
        ]

        var publicKey, privateKey: SecKey?

        let status = SecKeyGeneratePair(attributes as CFDictionary, &publicKey, &privateKey)
        if status == errSecSuccess {
            self.publicKey = publicKey
            self.privateKey = privateKey
        }
    }

    // Decrypt an AES key with the private key
    internal func decryptAESKeyWithPrivateKey(encryptedAESKey: Data) -> Data? {
        guard let privateKey = self.privateKey else {
            return nil
        }

        var error: Unmanaged<CFError>?

        guard let decryptedData = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionOAEPSHA256, encryptedAESKey as CFData, &error) as Data? else {
            print("Decryption of AES key failed: \(error?.takeRetainedValue() as Error?)")
            return nil
        }

        return decryptedData
    }

    // Decrypt plain text with the AES key
    internal func decryptCipherTextWithAES(cipherText: Data, aesKeyData: Data) -> String? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: cipherText)
            let decryptedData = try AES.GCM.open(sealedBox, using: SymmetricKey(data: aesKeyData))
            if let decryptedString = String(data: decryptedData, encoding: .utf8) {
                return decryptedString
            } else {
                print("Failed to decode decrypted data.")
            }
        } catch {
            print("AES decryption failed: \(error.localizedDescription)")
        }

        return nil
    }
    
    // Convert a SecKey to a PEM-encoded string
    internal static func secKeyToString(_ key: SecKey) -> String? {
        var error: Unmanaged<CFError>?
        if let data = SecKeyCopyExternalRepresentation(key, &error) as Data? {
            return data.base64EncodedString()
        } else {
            print("Error converting SecKey to string: \(error?.takeRetainedValue() as Error?)")
            return nil
        }
    }

}
