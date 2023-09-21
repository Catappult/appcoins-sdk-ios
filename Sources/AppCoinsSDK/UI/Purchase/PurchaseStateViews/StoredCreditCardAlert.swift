//
//  File.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import SwiftUI

struct StoredCreditCardAlert: View {
    
    init() {
        if let alertController = AdyenController.shared.presentableComponent?.viewController, let rootViewController = UIApplication.shared.windows.first?.rootViewController,
               let presentedPurchaseVC = rootViewController.presentedViewController as? PurchaseViewController {
                alertController.removeFromParent()
                presentedPurchaseVC.present(alertController, animated: true)
        }
    }
    
    var body: some View {
        EmptyView()
            .animation(.easeInOut(duration: 0.3))
    }
}
