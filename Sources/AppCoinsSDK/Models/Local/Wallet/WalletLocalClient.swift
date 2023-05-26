//
//  File.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation
import web3swift
import Web3Core

class WalletLocalClient : WalletLocalService {
    
    private var keystoreURL: URL?
    
    init() {
        do {
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let keystore = documentsDirectory.appendingPathComponent("wallet_keystore")
            try FileManager.default.createDirectory(at: keystore, withIntermediateDirectories: true, attributes: nil)
            self.keystoreURL = keystore
        } catch {
            self.keystoreURL = nil
        }
    }
    
    func getActiveWallet() -> Wallet? {
        if let keystoreURL = keystoreURL {
            // get active wallet address
            let active_address = Utils.readFromPreferences(key: "default-appcoins-wallet")
            
            if (active_address != "") {
                // get active wallet password
                let active_password = Utils.readFromKeychain(key: active_address)
                
                if active_password != nil {
                    let keystore = keystoreURL.appendingPathComponent(active_address)
                    return Wallet(keystore, active_password!)
                
                // TODO deal with no address on keychain – onboarding wallet
                } else { return nil }
                
            // TODO deal with no address on keychain – onboarding wallet
            } else { return nil }
        }
        return nil
    }
    
    func createNewWallet() throws -> Wallet? {
        if let keystoreURL = keystoreURL {
            do {
                // generate a random password
                let password = Utils.generateRandomPassword()
                
                let keystore = try EthereumKeystoreV3.init(password: password)
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
                    
                    // make new address active
                    do {
                        try Utils.writeToPreferences(key: "default-appcoins-wallet", value: wallet_address!)
                        
                        return Wallet(fileURL, password)
                    }
                    catch {
                        try FileManager.default.removeItem(atPath: fileURL.path)
                        Utils.deleteFromKeychain(key: wallet_address!)
                        
                        Utils.log(message: "3: \(error.localizedDescription)")
                        throw WalletLocalErrors.failedToCreate
                    }
                } else {
                    print("Failed to create a new wallet address")
                    Utils.log(message: "4: Failed to create a new wallet address")
                    throw WalletLocalErrors.failedToCreate
                }
            } catch {
                Utils.log(message: "5: \(error.localizedDescription)")
                throw WalletLocalErrors.failedToCreate
            }
        }
        return nil
    }
}
