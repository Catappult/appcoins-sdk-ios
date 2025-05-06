//
//  ProviderViewModel.swift
//
//
//  Created by aptoide on 05/05/2025.
//

import Foundation
@_implementationOnly import WebKit

internal class ProviderViewModel: ObservableObject {
    
    internal static var shared: ProviderViewModel = ProviderViewModel()
    
    @Published internal var isChoosingProvider = false
    
    // Device Orientation
    @Published internal var orientation: Orientation = .portrait
    
    private init() {}
    
    internal func reset() {
        self.isChoosingProvider = false
    }
    
    internal func showProviderChoice() {
        DispatchQueue.main.async { self.isChoosingProvider = true }
    }
    
    internal func chooseProvider(provider: PurchaseProvider) {
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController,
           let presentedProviderVC = rootViewController.presentedViewController as? ProviderViewController {
            
            DispatchQueue.main.async {
                presentedProviderVC.dismissProviderChoice() {
                    self.isChoosingProvider = false
                    self.reset()
                    NotificationCenter.default.post(name: NSNotification.Name("APPCProviderChoice"), object: nil, userInfo: ["ProviderChoice" : provider])
                }
            }
        }
    }
    
    // Handles the dismiss (click on the zone above the bottom sheet) for the multiple states of the bottom sheet
    internal func dismiss() {
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController,
           let presentedProviderVC = rootViewController.presentedViewController as? ProviderViewController {
            
            DispatchQueue.main.async {
                presentedProviderVC.dismissProviderChoice() {
                    self.isChoosingProvider = false
                    self.reset()
                    NotificationCenter.default.post(name: NSNotification.Name("APPCProviderChoice"), object: nil, userInfo: ["ProviderChoice" : nil])
                }
            }
        }
    }
    
    internal func setOrientation(orientation: Orientation) { self.orientation = orientation }
}
