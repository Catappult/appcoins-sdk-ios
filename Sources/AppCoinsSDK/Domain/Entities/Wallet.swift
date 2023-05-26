//
//  File.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation
import CryptoKit
import CryptoSwift
import web3swift
import Web3Core

class Wallet {
    
    var name: String?
    var balance: Balance?
    var address: String?
    var creationDate: Date
    
    private let password: String
    private let keystore: EthereumKeystoreV3
    private let transactionService: AppCoinTransactionService = AppCoinTransactionClient()
    private let billingService: AppCoinBillingService = AppCoinBillingClient()
    
    init? (_ keystoreUrl: URL, _ password: String = "") {
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
    
    func getBalance(wa: String, currency: Coin, completion: @escaping (Result<Balance, AppcTransactionError>) -> Void) {
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
    
    func getPrivateKey() -> Data {
        let ethereumAddress = EthereumAddress(getWalletAddress())!
        return try! keystore.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress)
    }
    
    func getWalletAddress() -> String {
        return self.keystore.addresses!.first!.address
    }

    func getSignedWalletAddress() -> String {
         let wa = keystore.addresses!.first
         let waChecksum = EthereumAddress.toChecksumAddress(getWalletAddress())
         let normalized = "\\x19Ethereum Signed Message:\n\(wa!.address.count)\(wa!.address)"
         let hash = Digest.sha3(normalized.bytes, variant: .keccak256)
         let (compressedSignature, _) = SECP256K1.signForRecovery(hash: Data(hash), privateKey: getPrivateKey(), useExtraEntropy: false)
         let signatureHex = compressedSignature!.toHexString()
         return signatureHex
     }
    
}
