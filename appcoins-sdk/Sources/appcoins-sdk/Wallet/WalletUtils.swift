//
//  WalletUtils.swift
//  appcoins-sdk
//
//  Created by aptoide on 03/03/2023.
//

import Foundation
import UIKit
import CryptoKit
//import Web3Core
//import CryptoSwift

struct WalletUtils {
    static func isWalletInstalled() -> Bool {
        let walletURL = URL(string: "com.aptoide.appcoins-wallet://")!
        return UIApplication.shared.canOpenURL(walletURL)
    }
    
    static func getWalletAddress() -> String {
        if let sharedDefaults = UserDefaults(suiteName: "group.com.appcoins-wallet.shared") {
            let walletAddress = sharedDefaults.string(forKey: "default-appcoins-wallet") ?? ""
            return walletAddress
        } else {
            return "No wallet address found"
        }
    }
    
    static func getWalletSignature() -> String {
        
        return "signature"
        
//        let walletAddress = getWalletAddress()
//        let waChecksum = EthereumAddress.toChecksumAddress(walletAddress)
//        let normalized = "\\x19Ethereum Signed Message:\n\(walletAddress.count)\(walletAddress)"
//        let hash = Digest.sha3(normalized.bytes, variant: .keccak256)
//        let (compressedSignature, _) = SECP256K1.signForRecovery(hash: Data(hash), privateKey: getPrivateKey(), useExtraEntropy: false)
//        let signatureHex = compressedSignature!.toHexString()
//        return signatureHex
    }
    
//    func getPrivateKey() -> Data {
//        let ethereumAddress = EthereumAddress(getWalletAddress())!
//        return try! keystore.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress)
//    }
}
