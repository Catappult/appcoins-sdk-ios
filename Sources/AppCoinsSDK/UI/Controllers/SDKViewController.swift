//
//  SDKViewController.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI

internal struct SDKViewController {
    
    internal static func presentPurchase() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        let purchaseViewController = PurchaseViewController()
        purchaseViewController.modalPresentationStyle = .overFullScreen
        rootViewController.present(purchaseViewController, animated: false, completion: nil)
    }
    
    internal static func presentProvider() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        let providerViewController = ProviderViewController()
        providerViewController.modalPresentationStyle = .overFullScreen
        rootViewController.present(providerViewController, animated: false, completion: nil)
    }
}
