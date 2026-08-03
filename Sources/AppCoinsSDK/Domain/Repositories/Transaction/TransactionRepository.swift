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

    internal func getAllTransactions(domain: String, wa: Wallet, completion: @escaping (Result<[Transaction], ProductServiceError>) -> Void) {
        productService.getAllPurchases(domain: domain, wa: wa) { result in
            switch result {
            case .success(let raws):
                completion(.success(raws.map { Transaction(raw: $0) }))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    internal func getLatestTransaction(domain: String, sku: String, wa: Wallet, completion: @escaping (Result<Transaction?, ProductServiceError>) -> Void) {
        productService.getAllPurchasesBySKU(domain: domain, sku: sku, wa: wa) { result in
            switch result {
            case .success(let raws):
                completion(.success(raws.first.map { Transaction(raw: $0) }))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    internal func getTransactionsByState(domain: String, state: [String], wa: Wallet, completion: @escaping (Result<[Transaction], ProductServiceError>) -> Void) {
        productService.getPurchasesByState(domain: domain, state: state, wa: wa) { result in
            switch result {
            case .success(let raws):
                completion(.success(raws.map { Transaction(raw: $0) }))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    internal func acknowledgeTransaction(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        productService.acknowledgePurchase(domain: domain, uid: uid, wa: wa) { result in completion(result) }
    }

    internal func consumeTransaction(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        productService.consumePurchase(domain: domain, uid: uid, wa: wa) { result in completion(result) }
    }

    internal func verifyTransaction(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Transaction, ProductServiceError>) -> Void) {
        productService.getPurchaseInformation(domain: domain, uid: uid, wa: wa) { result in
            switch result {
            case .success(let purchaseRaw):
                self.productService.getDeveloperPublicKey(domain: domain) { result in
                    switch result {
                    case .success(let publicKeyString):
                        let verified = self.verifySignature(
                            publicKeyString: publicKeyString,
                            signature: purchaseRaw.verification.signature,
                            message: purchaseRaw.verification.originalData
                        )
                        if verified {
                            completion(.success(Transaction(raw: purchaseRaw)))
                        } else {
                            completion(.failure(.purchaseVerificationFailed(
                                message: "Failed to verify transaction",
                                description: "Transaction signature is invalid at TransactionRepository.swift:verifyTransaction",
                                request: nil
                            )))
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

    private func verifySignature(publicKeyString: String, signature: String, message: String) -> Bool {
        let trimmedPublicKeyString = publicKeyString
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "\\r\\n", with: "\n")
            .replacingOccurrences(of: "\\/", with: "/")

        let base64Key = trimmedPublicKeyString
            .components(separatedBy: "\n")
            .filter { !$0.hasPrefix("-----BEGIN") && !$0.hasPrefix("-----END") }
            .joined()

        guard let keyData = Data(base64Encoded: base64Key, options: .ignoreUnknownCharacters),
              let signatureData = Data(base64Encoded: signature),
              let messageData = message.data(using: .utf8) else {
            Utils.log("Failed to decode key, signature or message at TransactionRepository.swift:verifySignature")
            return false
        }

        guard let strippedKeyData = stripPublicKeyHeader(keyData: keyData) else {
            Utils.log("Failed to strip public key header at TransactionRepository.swift:verifySignature")
            return false
        }

        let attributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: NSNumber(value: strippedKeyData.count * 8)
        ]

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(strippedKeyData as CFData, attributes as CFDictionary, &error) else {
            Utils.log("Failed to create SecKey at TransactionRepository.swift:verifySignature")
            return false
        }

        let isVerified = SecKeyVerifySignature(secKey, .rsaSignatureMessagePKCS1v15SHA1, messageData as CFData, signatureData as CFData, &error)

        if isVerified {
            Utils.log("Transaction signature verified successfully at TransactionRepository.swift:verifySignature")
        } else {
            Utils.log("Transaction signature verification failed at TransactionRepository.swift:verifySignature")
        }

        return isVerified
    }

    private func stripPublicKeyHeader(keyData: Data) -> Data? {
        var index = 0
        let count = keyData.count

        guard count > 0, keyData[index] == 0x30 else { return nil }
        index += 1
        index = advancePastLength(in: keyData, from: index)

        if keyData[index] == 0x02 { return keyData }

        guard keyData[index] == 0x30 else { return nil }
        index += 1
        let algLength = consumeLength(in: keyData, from: &index)
        index += algLength

        guard index < count, keyData[index] == 0x03 else { return nil }
        index += 1
        _ = consumeLength(in: keyData, from: &index)

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
        if first < 0x80 { return Int(first) }
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
