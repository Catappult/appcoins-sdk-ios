//
//  WalletLocalClient.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation
@_implementationOnly import web3swift
@_implementationOnly import Web3Core

internal class WalletLocalClient : WalletLocalService {
    
    private var keystoreURL: URL?
    
    internal init() {
        do {
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let keystore = documentsDirectory.appendingPathComponent("wallet_keystore")
            try FileManager.default.createDirectory(at: keystore, withIntermediateDirectories: true, attributes: nil)
            self.keystoreURL = keystore
        } catch {
            self.keystoreURL = nil
        }
    }
    
    internal func getActiveWallet() -> ClientWallet? {
        if let keystoreURL = keystoreURL {
            // get active wallet address
            let active_address = Utils.readFromPreferences(key: "default-appcoins-wallet")
            
            if (active_address != "") {
                // get active wallet password
                let active_password = Utils.readFromKeychain(key: active_address)
                
                if active_password != nil {
                    let keystore = keystoreURL.appendingPathComponent(active_address)
                    return ClientWallet(keystore, active_password!)
                
                } else { return nil }
                
            } else { return nil }
        }
        return nil
    }
    
    internal func getWalletList() -> [ClientWallet] {
        if let keystoreURL = keystoreURL {
            do {
                var walletList: [ClientWallet] = []
                let keystores = try FileManager.default.contentsOfDirectory(at: keystoreURL, includingPropertiesForKeys: nil)
                for keystore in keystores {
                    let keystore_password = Utils.readFromKeychain(key: keystore.lastPathComponent)
                    if keystore_password != nil {
                        if let wallet = ClientWallet(keystore, keystore_password!) {
                            walletList.append(wallet)
                        }
                    }
                }
                return walletList
            } catch {
                return []
            }
        }
        
        return []
    }
    
    internal func createNewWallet() throws -> ClientWallet? {
        if let keystoreURL = keystoreURL {
            do {
                // generate a random password
                let password = Utils.generateRandomPassword()
                let private_key = Utils.generatePrivateKey()
                
                let keystore = try EthereumKeystoreV3.init(privateKey: private_key, password: password)
                let wallet_address = keystore?.getAddress()?.address
                let data = try JSONEncoder().encode(keystore?.keystoreParams)
                
                if wallet_address != nil {
                    let fileURL = keystoreURL.appendingPathComponent(wallet_address!)
                    
                    do { try data.write(to: (fileURL)) } catch {
                        Utils.log(message: "1: \(error.localizedDescription)")
                        throw WalletLocalErrors.failedToCreate
                    }
                    
                    // store address password
                    do { try Utils.writeToKeychain(key: wallet_address!, value: password) }
                    catch {
                        try FileManager.default.removeItem(atPath: fileURL.path)
                        
                        Utils.log(message: "2: \(error.localizedDescription)")
                        throw WalletLocalErrors.failedToCreate
                    }
                    
                    // store private key
                    do {
                        try Utils.writeToKeychain(key: "\(wallet_address!)-pk", value: private_key.base64EncodedString())
                    }
                    catch {
                        try FileManager.default.removeItem(atPath: fileURL.path)
                        Utils.deleteFromKeychain(key: "\(wallet_address!)-pk")
                        
                        Utils.log(message: "\(error.localizedDescription)")
                        throw WalletLocalErrors.failedToCreate
                    }
                    
                    // make new address active
                    do {
                        try Utils.writeToPreferences(key: "default-appcoins-wallet", value: wallet_address!)
                        
                        return ClientWallet(fileURL, password)
                    }
                    catch {
                        try FileManager.default.removeItem(atPath: fileURL.path)
                        Utils.deleteFromKeychain(key: "\(wallet_address!)-pk")
                        Utils.deleteFromKeychain(key: wallet_address!)
                        
                        Utils.log(message: "4: \(error.localizedDescription)")
                        throw WalletLocalErrors.failedToCreate
                    }
                } else {
                    print("Failed to create a new wallet address")
                    Utils.log(message: "5: Failed to create a new wallet address")
                    throw WalletLocalErrors.failedToCreate
                }
            } catch {
                Utils.log(message: "6: \(error.localizedDescription)")
                throw WalletLocalErrors.failedToCreate
            }
        }
        return nil
    }
    
    internal func importWallet(keystore: String, password: String, privateKey: String, completion: @escaping (Result<ClientWallet?, WalletLocalErrors>) -> Void) {
        if let keystoreURL = keystoreURL {
            if let keystoreData = keystore.data(using: .utf8), let jsonObject = try? JSONSerialization.jsonObject(with: keystoreData, options: []) as? [String: Any] {
                if let address = jsonObject["address"] as? String {
                    let fileURL = keystoreURL.appendingPathComponent(address)
                    
                    do { try keystoreData.write(to: (fileURL)) } catch {
                        Utils.log(message: "1: \(error.localizedDescription)")
                        completion(.failure(WalletLocalErrors.failedToCreate))
                    }
                    
                    // store address password
                    do { try Utils.writeToKeychain(key: address, value: password) }
                    catch {
                        try? FileManager.default.removeItem(atPath: fileURL.path)
                        
                        Utils.log(message: "2: \(error.localizedDescription)")
                        completion(.failure(WalletLocalErrors.failedToCreate))
                    }
                    
                    // store private key
                    do {
                        try Utils.writeToKeychain(key: "\(address)-pk", value: privateKey)
                    }
                    catch {
                        try? FileManager.default.removeItem(atPath: fileURL.path)
                        Utils.deleteFromKeychain(key: "\(address)-pk")
                        
                        Utils.log(message: "\(error.localizedDescription)")
                        completion(.failure(WalletLocalErrors.failedToCreate))
                    }
                    
                } else { completion(.failure(WalletLocalErrors.failedToCreate)) }
            } else { completion(.failure(WalletLocalErrors.failedToCreate)) }
        } else { completion(.failure(WalletLocalErrors.failedToCreate)) }
    }
    
    internal func getPrivateKey(wallet: Wallet) -> Data? {
        if let privateKeyString = Utils.readFromKeychain(key: "\(wallet.getWalletAddress())-pk") {
            return Data(base64Encoded: privateKeyString)
        } else {
            return nil
        }
    }
}
