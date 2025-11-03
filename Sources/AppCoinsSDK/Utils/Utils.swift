//
//  Utils.swift
//
//
//  Created by aptoide on 03/03/2023.
//

import SwiftUI
@_implementationOnly import os
@_implementationOnly import Security
@_implementationOnly import CommonCrypto

internal struct Utils {
    
    static internal let bottomSafeAreaHeight: CGFloat = UIApplication.shared.windows[0].safeAreaInsets.bottom
    static internal let topSafeAreaHeight: CGFloat = UIApplication.shared.windows[0].safeAreaInsets.top
    
    static internal func writeToFile(
        directory: FileManager.SearchPathDirectory = .applicationSupportDirectory,
        domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
        filename: String,
        content: Data
    ) {
        let baseURL = FileManager.default.urls(for: directory, in: domainMask)[0]
        let fileURL = baseURL.appendingPathComponent(filename)
        
        let folderURL = fileURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        
        try? content.write(to: fileURL, options: .atomic)
    }
    
    static internal func readFromFile(
        directory: FileManager.SearchPathDirectory = .applicationSupportDirectory,
        domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
        filename: String
    ) -> Data? {
        let fileURL: URL = FileManager.default.urls(for: directory, in: domainMask)[0].appendingPathComponent(filename)
        return try? Data(contentsOf: fileURL)
    }
    
    static internal func deleteFile(
        directory: FileManager.SearchPathDirectory = .applicationSupportDirectory,
        domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
        filename: String
    ) {
        let fileURL: URL = FileManager.default.urls(for: directory, in: domainMask)[0].appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    static internal func writeToPreferences(key: String, value: String?) throws -> Void {
        let preferences = UserDefaults.standard
        if value != nil { preferences.setValue(value, forKey: key) } else { preferences.removeObject(forKey: key) }
        
        // Save to disk
        let didSave = preferences.synchronize()
        if !didSave { throw PreferencesError.error }
    }
    
    static internal func deleteFromPreferences(key: String) -> Void {
        let preferences = UserDefaults.standard
        preferences.removeObject(forKey: key)
        
        // Save to disk
        let didSave = preferences.synchronize()
    }
    
    static internal func readFromPreferences(key: String) -> String {
        let preferences = UserDefaults.standard
        return preferences.string(forKey: key) ?? ""
    }
    
    static internal func writeToKeychain<T: Codable>(key: String, value: T) throws {
        try KeychainHelper.shared.save(value, service: key, account: "com.aptoide.appcoins-wallet")
    }

    static internal func readFromKeychain<T: Codable>(key: String, type: T.Type) -> T? {
        return KeychainHelper.shared.read(service: key, account: "com.aptoide.appcoins-wallet", type: type)
    }

    static internal func deleteFromKeychain(key: String) -> Void {
        KeychainHelper.shared.delete(service: key, account: "com.aptoide.appcoins-wallet")
    }
    
    static internal func log(_ message: String, category: String = "Debug") {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: category)
        let message = "[AppCoinsSDK] \(message)"
        logger.error("\(message, privacy: .public)")
    }
    
    static internal func purchaseResult(result: PurchaseResult) {
        NotificationCenter.default.post(name: NSNotification.Name("APPCPurchaseResult"), object: nil, userInfo: ["PurchaseResult" : result])
    }
    
    static func md5(_ string: String) -> String {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes { digestBytes in
            messageData.withUnsafeBytes { messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
    
    static internal func getAppIcon() -> UIImage {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {

            return UIImage(named: lastIcon) ?? UIImage()
        }
        return UIImage()
    }
}
