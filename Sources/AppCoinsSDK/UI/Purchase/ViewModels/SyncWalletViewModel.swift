//
//  SyncWalletViewModel.swift
//  
//
//  Created by aptoide on 18/10/2023.
//

import Foundation
import UIKit

// Helper to the BottomSheetViewModel
internal class SyncWalletViewModel : ObservableObject {
    
    internal static var shared : SyncWalletViewModel = SyncWalletViewModel()
    
    internal var transactionUseCases: TransactionUseCases = TransactionUseCases.shared
    internal var walletUseCases: WalletUseCases = WalletUseCases.shared
    internal var bottomSheetViewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    @Published internal var syncDismissAnimation: Bool = true
    
    private init() {}
    
    // Start the import Wallet request to the Wallet app through a deep link
    // Generate assymetric keys and pass the public key to the wallet for encryption of the data
    // This will ensure that the app that triggers the Wallet import is the only one that can
    // access the user's Wallet
    internal func importWallet() {
        
        if let publicKey = SecureEnvelopeClient.shared.publicKey, let publicKeyString = SecureEnvelopeClient.secKeyToString(publicKey) {
            
            let walletPath = "com.aptoide.appcoins-wallet.sync://"
            let refererUrlEndpoint = "wallet.appcoins.io/sync"
            let parameters = "?return=\(Bundle.main.bundleIdentifier!).iap&pk=\(publicKeyString)"
            let fullUrl = walletPath + refererUrlEndpoint + parameters
            
            UIApplication.shared.open(URL(string: fullUrl)!, options: [:]) { result in self.bottomSheetViewModel.setPurchaseState(newState: .syncProcessing) }
        }
    }
    
    // Deal with the redirect from the AppCoins Wallet app to import the user's wallet
    // Arguments passed include the wallet's keystore, private key and password, and the symmetric key used for the Secure Envelope communication
    internal func importWalletReturn(redirectURL: URL) {
        if redirectURL.pathComponents[2] == "success" {
            // 1. Get the variables from the Deeplink sent by the Wallet
            if let (password, keystore, privateKey, symmetricKey) = self.getImportWalletURLVariables(URL: redirectURL) {
                
                // 2. Transform the variables from plain text to Data
                if let (passwordData, keystoreData, privateKeyData, symmetricKeyData) = self.encryptedImportWalletVariablesToData(password: password, keystore: keystore, privateKey: privateKey, symmetricKey: symmetricKey) {
                    
                    // 3. Decrypt the Password, Keystore and Private Key
                    if let (decryptedPassword, decryptedKeystore, decryptedPrivateKey) = self.decryptImportWalletVariables(passwordData: passwordData, keystoreData: keystoreData, privateKeyData: privateKeyData, symmetricKeyData: symmetricKeyData) {
                        
                        // 4. Transfer the APPC accumulated in the old wallet to the imported wallet
                        self.transferAPPCToImportedWallet(keystore: decryptedKeystore) {
                            error in
                            
                            if error == nil {
                                // 5. Replace the user wallet on the file system
                                self.walletUseCases.importWallet(keystore: decryptedKeystore, password: decryptedPassword, privateKey: decryptedPrivateKey) {
                                    result in
                                    
                                    switch result {
                                    case .success(_):
                                        DispatchQueue.main.async { self.bottomSheetViewModel.setPurchaseState(newState: .syncSuccess) }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.syncDismissAnimation = false }
                                        if self.bottomSheetViewModel.hasCompletedPurchase() {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.bottomSheetViewModel.dismiss() }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { self.syncDismissAnimation = true }
                                        } else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.transactionViewModel.buildTransaction() }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { self.syncDismissAnimation = true }
                                        }
                                    case .failure(_): self.syncFailed()
                                    }
                                }
                            } else { self.syncFailed() }
                        }
                    } else { self.syncFailed() }
                } else { self.syncFailed() }
            }
        } else { self.syncFailed() }
    }
    
    // Handles Wallet Sync failure
    private func syncFailed() {
        DispatchQueue.main.async { self.bottomSheetViewModel.setPurchaseState(newState: .syncError) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.syncDismissAnimation = false }
        if self.bottomSheetViewModel.hasCompletedPurchase() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.bottomSheetViewModel.dismiss() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { self.syncDismissAnimation = true }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.transactionViewModel.buildTransaction() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { self.syncDismissAnimation = true }
        }
    }
    
    // Extract the variables from Wallet Import Redirect URL
    private func getImportWalletURLVariables(URL: URL) -> (String, String, String, String)? {
        let queryItems = URLComponents(url: URL, resolvingAgainstBaseURL: false)?.queryItems
        if let password = queryItems?.first(where: {$0.name == "pw"})?.value,
            let keystore = queryItems?.first(where: {$0.name == "ks"})?.value,
            let privateKey = queryItems?.first(where: {$0.name == "pk"})?.value,
            let symmetricKey = queryItems?.first(where: {$0.name == "sk"})?.value {
            return (password, keystore, privateKey, symmetricKey)
        } else {
            return nil
        }
    }

    // Transform the import variables to Data in order to decrypt them later on
    private func encryptedImportWalletVariablesToData(password: String, keystore: String, privateKey: String, symmetricKey: String) -> (Data, Data, Data, Data)? {
        
        if let passwordData = Data(base64Encoded: password),
           let keystoreData = Data(base64Encoded: keystore),
           let privateKeyData = Data(base64Encoded: privateKey),
           let symmetricKeyData = Data(base64Encoded: symmetricKey) {
            return (passwordData, keystoreData, privateKeyData, symmetricKeyData)
        } else { return nil }
        
    }
    
    // Decrypt the variables necessary to import the wallet
    private func decryptImportWalletVariables(passwordData: Data, keystoreData: Data, privateKeyData: Data, symmetricKeyData: Data) -> (String, String, String)? {
        
        // 1. Use the private key created on the start of the import process to decrypt the symmetric key
        if let aesKey = SecureEnvelopeClient.shared.decryptAESKeyWithPrivateKey(encryptedAESKey: symmetricKeyData) {
            
            // 2. Use the decrypted symmetric key to decrypt the wallet's variables
            if let decryptedPassword = SecureEnvelopeClient.shared.decryptCipherTextWithAES(cipherText: passwordData, aesKeyData: aesKey), let decryptedKeystore = SecureEnvelopeClient.shared.decryptCipherTextWithAES(cipherText: keystoreData, aesKeyData: aesKey), let decryptedPrivateKey = SecureEnvelopeClient.shared.decryptCipherTextWithAES(cipherText: privateKeyData, aesKeyData: aesKey) {
                
                return (decryptedPassword, decryptedKeystore, decryptedPrivateKey)
                
            } else { return nil }
        } else { return nil }
    }
    
    // Transfer the APPC accumulated on the SDK's Wallet to the user's Wallet
    // The user will keep the APPC's but not the gamification level associated with the SDK's Wallet
    private func transferAPPCToImportedWallet(keystore: String, completion: @escaping (TransactionError?) -> Void) {
        
        // 1. Get the address of the user's Wallet from the decrypted keystore
        if let keystoreData = keystore.data(using: .utf8), let jsonObject = try? JSONSerialization.jsonObject(with: keystoreData, options: []) as? [String: Any], let address = jsonObject["address"] as? String {
            
            // 2. Get the SDK's Wallet address
            if let currentWallet = self.walletUseCases.getClientWallet(), let currentWalletAddress = currentWallet.address {
                
                // 3. Get the current APPC balance from the SDKs Wallet to transfer it to the user's Wallet
                currentWallet.getBalance(wa: currentWalletAddress, currency: .APPC) {
                    result in
                    switch result {
                    case .success(let balance):
                        if balance.appcoinsBalance == 0 { completion(nil) }
                        else {
                            // APPC Balance must be rounded down to be transferred
                            let roundedBalance = String(format: "%.2f", floor(balance.appcoinsBalance * 100) / 100)
                            let raw = TransferAPPCRaw.from(price: roundedBalance, currency: "APPC", userWa: address)
                            
                            // 4. Transfer the APPC from the SDK Wallet to the user's Wallet
                            self.transactionUseCases.transferAPPC(wa: currentWallet, raw: raw) {
                                result in
                                
                                switch result {
                                case .success(_):
                                    completion(nil)
                                case .failure(_):
                                    completion(.failed())
                                }
                            }
                        }
                    case .failure(_):
                        completion(.failed())
                    }
                }
            } else { completion(.failed()) }
        } else { completion(.failed()) }
    }
    
    // Install the AppCoins Wallet App
    internal func installWallet() {
        let storePath = "com.aptoide.aptoide-store://"
        let refererUrlEndpoint = "aptoide.com/app/com.aptoide.appcoins-wallet?action=install"
        let fullUrl = storePath + refererUrlEndpoint
        
        UIApplication.shared.open(URL(string: fullUrl)!, options: [:]) {
            didOpen in
            
            if !didOpen {
                UIApplication.shared.open(URL(string: "https://appcoins-wallet.en.aptoide.com/app")!, options: [:])
            }
        }
    }
}
