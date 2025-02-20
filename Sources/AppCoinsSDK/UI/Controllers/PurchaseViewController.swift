//
//  PurchaseViewController.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI

internal class PurchaseViewController: UIViewController {
    
    @ObservedObject private var keyboardObserver = KeyboardObserver.shared
    internal var orientation: UIInterfaceOrientationMask = .landscape
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        updateOrientation()
        
        overrideUserInterfaceStyle = .light
        
        // Add the bottom sheet view
        let bottomSheetView = BottomSheetView()
        let content: () -> UIView = {
            return bottomSheetView.toUIView()
        }
        let wrapperView = BottomSheetWrapperView(content: content)
        self.view.addSubview(wrapperView)
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: self.view.topAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func updateOrientation() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if scene.interfaceOrientation == .landscapeLeft || scene.interfaceOrientation == .landscapeRight {
                BottomSheetViewModel.shared.setOrientation(orientation: .landscape)
                orientation = .landscape
            } else {
                BottomSheetViewModel.shared.setOrientation(orientation: .portrait)
                orientation = .portrait
            }
        }
    }
    
    override internal var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return orientation
        }
    
    @objc internal func dismissPurchase() {
        self.dismiss(animated: false, completion: nil)
    }
    
    internal func presentLogoutAlert() {
        let alert = UIAlertController(title: Constants.logOut, message: Constants.confirmLogOutText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.cancelText, style: .cancel))
        alert.addAction(UIAlertAction(title: Constants.logOut, style: .destructive, handler: { _ in
            AuthViewModel.shared.logout()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    internal func presentPayPalLogoutAlert() {
        let alert = UIAlertController(title: Constants.logOut, message: Constants.confirmLogOutText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.cancelText, style: .cancel))
        alert.addAction(UIAlertAction(title: Constants.logOut, style: .destructive, handler: { _ in
            PayPalDirectViewModel.shared.logoutPayPal()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
