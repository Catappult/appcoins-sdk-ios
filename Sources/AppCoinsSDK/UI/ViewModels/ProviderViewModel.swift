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
    
    @Published internal var product: Product?
    @Published internal var userCurrency: Currency?
    
    // Device Orientation
    @Published internal var orientation: Orientation = .portrait
    
    private init() {}
    
    internal func reset() {
        self.product = nil
        self.userCurrency = nil
    }
    
    internal func loadProviderPurchase(domain: String, for product: Product) {
        CurrencyUseCases.shared.getUserCurrency { result in
            switch result {
            case .success(let currency):
                DispatchQueue.main.async{ self.userCurrency = currency }
                
                ProductUseCases.shared.getProduct(domain: domain, product: product.sku, discountPolicy: .D2C) { result in
                    switch result {
                    case .success(let product):
                        DispatchQueue.main.async{ self.product = product }
                    case .failure(let failure):
                        break
                    }
                }
            case .failure(let failure):
                break
            }
        }
    }
    
    internal func chooseProvider(provider: PurchaseProvider) {
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController,
           let presentedProviderVC = rootViewController.presentedViewController as? ProviderViewController {
            
            DispatchQueue.main.async {
                presentedProviderVC.dismissProviderChoice() {
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
                    self.reset()
                    NotificationCenter.default.post(name: NSNotification.Name("APPCProviderChoice"), object: nil, userInfo: ["ProviderChoice" : nil])
                }
            }
        }
    }
    
    internal func setOrientation(orientation: Orientation) { self.orientation = orientation }
}
