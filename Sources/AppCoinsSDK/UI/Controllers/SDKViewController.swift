//
//  SDKViewController.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI
@_implementationOnly import SafariServices

internal struct SDKViewController {
    
    internal static func presentPurchase() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        let purchaseViewController = PurchaseViewController()
        purchaseViewController.modalPresentationStyle = .overFullScreen
        rootViewController.present(purchaseViewController, animated: false, completion: nil)
    }
    
    internal static func presentSafariSheet(url: URL) {
        guard let topViewController = UIApplication.shared.topMostViewController() else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .pageSheet
        topViewController.present(safariVC, animated: true)
    }
}
