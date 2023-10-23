//
//  Wallet.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation
import CryptoKit
import CryptoSwift
import web3swift
import Web3Core

internal class Wallet {
    
    internal var name: String?
    internal var balance: Balance?
    internal var address: String?
    internal var creationDate: Date
    
    private let password: String
    private let keystore: EthereumKeystoreV3
    private let transactionService: AppCoinTransactionService = AppCoinTransactionClient()
    private let billingService: AppCoinBillingService = AppCoinBillingClient()
    private let walletService: WalletLocalService = WalletLocalClient()
    
    internal init? (_ keystoreUrl: URL, _ password: String = "") {
        guard let data = try? Data(contentsOf: keystoreUrl) else { return nil }
        guard let keystoreParams = try? JSONDecoder().decode(AppCoinKeystoreRaw.self, from: data) else { return nil }
        self.keystore = EthereumKeystoreV3(keystoreParams.toJSON())!
        
        let attributes = try? FileManager.default.attributesOfItem(atPath: keystoreUrl.path)
        self.creationDate = attributes?[FileAttributeKey.creationDate] as? Date ?? Date()
        
        self.password = password
        self.address = self.keystore.addresses?.first?.address
        
        if let address = self.address {
            let bdname = Utils.readFromPreferences(key: address)
            if bdname != "" { self.name = bdname } else { self.name = address }
            
            getBalance(wa: address, currency: .EUR) {
                result in
                switch result {
                case .success(let balance):
                    self.balance = balance
                case .failure(_):
                    break
                }
            }
        }
    }
    
    internal func getBalance(wa: String, currency: Coin, completion: @escaping (Result<Balance, AppcTransactionError>) -> Void) {
        transactionService.getBalance(wa: wa) { result in
            switch result {
            case .success(let response):
                self.billingService.convertCurrency(money: String(response.usdBalance), fromCurrency: .USD, toCurrency: currency) {
                    result in
                    
                    switch result {
                    case .success(let currencyResponse):
                        let balance = Balance(balanceCurrency: currencyResponse.sign, balance: Double(currencyResponse.value) ?? 0.0, appcoinsBalance: response.appcNormalizedBalance)
                        completion(.success(balance))
                    case .failure(_):
                        completion(.failure(.failed))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
    
    internal func getPrivateKey() -> Data {
        if let privateKey = walletService.getPrivateKey(address: self.keystore.addresses!.first!.address) {
            return privateKey
        } else {
            let ethereumAddress = EthereumAddress(getWalletAddress())!
            let key = try! keystore.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress)
            return key
        }
    }
    
    internal func getWalletAddress() -> String {
        return self.keystore.addresses!.first!.address
    }

    internal func getSignedWalletAddress() -> String {
         let wa = keystore.addresses!.first
         let waChecksum = EthereumAddress.toChecksumAddress(getWalletAddress())
         let normalized = "\\x19Ethereum Signed Message:\n\(wa!.address.count)\(wa!.address)"
         let hash = Digest.sha3(normalized.bytes, variant: .keccak256)
         let (compressedSignature, _) = SECP256K1.signForRecovery(hash: Data(hash), privateKey: getPrivateKey(), useExtraEntropy: false)
         let signatureHex = compressedSignature!.toHexString()
         return signatureHex
     }
    
    internal func getEWT() -> String? {
        // Header
        let headerString = "{\"typ\":\"EWT\"}"
        let header = replaceInvalidCharacters(convertToBase64(headerString))
        
        if let payloadString = getPayload() {
            let payload = replaceInvalidCharacters(payloadString)
            let signedContent = signContent(content: payload)
            return "Bearer \(header).\(payload).\(signedContent)".replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
        }
        return nil
    }
    
    private func signContent(content: String) -> String {
        let normalized = "\\x19Ethereum Signed Message:\n\(content.count)\(content)"
        let hash = Digest.sha3(normalized.bytes, variant: .keccak256)
        let (compressedSignature, _) = SECP256K1.signForRecovery(hash: Data(hash), privateKey: getPrivateKey(), useExtraEntropy: false)
        let signatureHex = compressedSignature!.toHexString()
        return signatureHex
    }
    
    private func getPayload() -> String? {
        if let address = self.address {
            let timestamp = Int(Date().timeIntervalSince1970)
            // Variable representing in seconds the time to live interval of the authentication token.
            let TTL = 3600

            let unixTimeWithTTL = timestamp + TTL
            
            var payloadJson : [String : Any] = [:]
            payloadJson["iss"] = address
            payloadJson["exp"] = unixTimeWithTTL
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: payloadJson, options: []) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    return convertToBase64(jsonString)
                }
            }
        }
        return nil
    }
    
    private func convertToBase64(_ ewtString: String) -> String {
        return Data(ewtString.utf8).base64EncodedString()
    }
    
    private func replaceInvalidCharacters(_ ewtString: String) -> String {
        return ewtString
                    .replacingOccurrences(of: "=", with: "")
                    .replacingOccurrences(of: "+", with: "-")
                    .replacingOccurrences(of: "/", with: "_")
    }
}
