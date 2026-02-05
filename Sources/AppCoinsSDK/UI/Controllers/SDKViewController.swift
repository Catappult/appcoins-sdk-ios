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
    
    internal static var shared: SDKViewController = SDKViewController()
    
    internal var background: UIView?
    
    private init() {}
    
    internal func presentPurchase() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }

        let opaqueView = UIView(frame: rootViewController.view.bounds)

        if #available(iOS 14.0, *) {
            opaqueView.backgroundColor = UIColor(ColorsUi.APC_Black.opacity(0.3))
        }

        rootViewController.view.addSubview(opaqueView)
        SDKViewController.shared.background = opaqueView

        let purchaseViewController = PurchaseViewController()
        purchaseViewController.modalPresentationStyle = .overFullScreen
        rootViewController.present(purchaseViewController, animated: true, completion: nil)
    }

    internal func presentProvider() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }

        let opaqueView = UIView(frame: rootViewController.view.bounds)

        if #available(iOS 14.0, *) {
            opaqueView.backgroundColor = UIColor(ColorsUi.APC_Black.opacity(0.3))
        }

        rootViewController.view.addSubview(opaqueView)
        SDKViewController.shared.background = opaqueView

        let providerViewController = ProviderViewController()
        providerViewController.modalPresentationStyle = .overFullScreen
        rootViewController.present(providerViewController, animated: true, completion: nil)
    }
    
    internal func presentSafariSheet(url: URL) {
        guard let topViewController = UIApplication.shared.topMostViewController() else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .pageSheet
        topViewController.present(safariVC, animated: true)
    }
    
    internal func dismissBackground() {
        SDKViewController.shared.background?.removeFromSuperview()
    }
}
