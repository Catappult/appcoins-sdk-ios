//
//  TransactionRepository.swift
//
//
//  Created by aptoide on 15/05/2023.
//

import Foundation
import Security

internal class TransactionRepository: TransactionRepositoryProtocol {
    
    private let productService: AppCoinProductService = AppCoinProductServiceClient()
    
    internal func getAllPurchases(domain: String, wa: Wallet, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void) {
        productService.getAllPurchases(domain: domain, wa: wa) {
            result in
            switch result {
            case .success(let purchasesRaw):
                var purchases: [Purchase] = []
                for raw in purchasesRaw {
                    purchases.append(Purchase(raw: raw))
                }
                completion(.success(purchases))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    internal func getLatestPurchase(domain: String, sku: String, wa: Wallet, completion: @escaping (Result<Purchase?, ProductServiceError>) -> Void) {
        productService.getAllPurchasesBySKU(domain: domain, sku: sku, wa: wa) {
            result in
            switch result {
            case .success(let purchasesRaw):
                if let rawSKU = purchasesRaw.first {
                    let skuPurchase: Purchase = Purchase(raw: rawSKU)
                    completion(.success(skuPurchase))
                } else {
                    completion(.success(nil))
                }
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    internal func getPurchasesByState(domain: String, state: [String], wa: Wallet, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void) {
        productService.getPurchasesByState(domain: domain, state: state, wa: wa) {
            result in
            switch result {
            case .success(let purchasesRaw):
                var purchases: [Purchase] = []
                for raw in purchasesRaw {
                    purchases.append(Purchase(raw: raw))
                }
                completion(.success(purchases))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    internal func acknowledgePurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        productService.acknowledgePurchase(domain: domain, uid: uid, wa: wa) { result in completion(result) }
    }
    
    internal func consumePurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        productService.consumePurchase(domain: domain, uid: uid, wa: wa) { result in completion(result) }
    }
    
    internal func verifyPurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Purchase, ProductServiceError>) -> Void) {
        productService.getPurchaseInformation(domain: domain, uid: uid, wa: wa) {
            result in
            switch result {
            case .success(let purchaseRaw):
                self.productService.getDeveloperPublicKey(domain: domain) {
                    result in
                    switch result {
                    case .success(let publicKeyString):
                        let verified = self.verifyPurchaseSignature(publicKeyString: publicKeyString, signature: purchaseRaw.verification.signature, message: purchaseRaw.verification.originalData)
                        if verified {
                            completion(.success(Purchase(raw: purchaseRaw)))
                        } else {
                            completion(.failure(.purchaseVerificationFailed(message: "Failed to verify purchase", description: "Purchase is not verified at TransactionRepository.swift:verifyPurchase", request: nil)))
                        }
                    case .failure(let failure):
                        completion(.failure(failure))
                    }
                }
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    private func verifyPurchaseSignature(publicKeyString: String, signature: String, message: String) -> Bool {

        let trimmedPublicKeyString = publicKeyString
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "\\r\\n", with: "\n")
            .replacingOccurrences(of: "\\/", with: "/")

        // Extract base64 key data from PEM
        let base64Key = trimmedPublicKeyString
            .components(separatedBy: "\n")
            .filter { !$0.hasPrefix("-----BEGIN") && !$0.hasPrefix("-----END") }
            .joined()

        guard let keyData = Data(base64Encoded: base64Key, options: .ignoreUnknownCharacters),
              let signatureData = Data(base64Encoded: signature),
              let messageData = message.data(using: .utf8) else {
            Utils.log("Failed to decode key, signature or message data at TransactionRepository.swift:verifyPurchaseSignature")
            return false
        }

        // Strip X.509 SubjectPublicKeyInfo header to get raw RSA key data
        guard let strippedKeyData = stripPublicKeyHeader(keyData: keyData) else {
            Utils.log("Failed to strip public key header at TransactionRepository.swift:verifyPurchaseSignature")
            return false
        }

        let attributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: NSNumber(value: strippedKeyData.count * 8)
        ]

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(strippedKeyData as CFData, attributes as CFDictionary, &error) else {
            Utils.log("Failed to create SecKey at TransactionRepository.swift:verifyPurchaseSignature")
            return false
        }

        let isVerified = SecKeyVerifySignature(secKey, .rsaSignatureMessagePKCS1v15SHA1, messageData as CFData, signatureData as CFData, &error)

        if isVerified {
            Utils.log("Purchase signature verified successfully at TransactionRepository.swift:verifyPurchaseSignature")
        } else {
            Utils.log("Purchase signature verification failed at TransactionRepository.swift:verifyPurchaseSignature")
        }

        return isVerified
    }

    /// Strips the X.509 SubjectPublicKeyInfo header from a DER-encoded public key,
    /// returning the raw RSA key data that SecKeyCreateWithData expects.
    private func stripPublicKeyHeader(keyData: Data) -> Data? {
        var index = 0
        let count = keyData.count

        guard count > 0, keyData[index] == 0x30 else { return nil } // SEQUENCE
        index += 1
        index = advancePastLength(in: keyData, from: index)

        // Check if the next element is another SEQUENCE (X.509 header present)
        // If it's an INTEGER, the key is headerless — return as-is
        if keyData[index] == 0x02 { return keyData }

        // Skip the algorithm identifier SEQUENCE
        guard keyData[index] == 0x30 else { return nil }
        index += 1
        let algLength = consumeLength(in: keyData, from: &index)
        index += algLength

        // The next element should be a BIT STRING containing the key
        guard index < count, keyData[index] == 0x03 else { return nil }
        index += 1
        _ = consumeLength(in: keyData, from: &index)

        // Skip the unused bits byte in the BIT STRING
        guard index < count, keyData[index] == 0x00 else { return nil }
        index += 1

        return keyData.subdata(in: index..<count)
    }

    private func advancePastLength(in data: Data, from index: Int) -> Int {
        var idx = index
        _ = consumeLength(in: data, from: &idx)
        return idx
    }

    private func consumeLength(in data: Data, from index: inout Int) -> Int {
        guard index < data.count else { return 0 }
        let first = data[index]
        index += 1
        if first < 0x80 {
            return Int(first)
        }
        let numBytes = Int(first & 0x7F)
        var length = 0
        for _ in 0..<numBytes {
            guard index < data.count else { return 0 }
            length = (length << 8) | Int(data[index])
            index += 1
        }
        return length
    }
}
