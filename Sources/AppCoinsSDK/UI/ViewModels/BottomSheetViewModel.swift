//
//  BottomSheetViewModel.swift
//
//
//  Created by aptoide on 08/03/2023.
//

import Foundation
import SwiftUI
@_implementationOnly import Combine

internal class BottomSheetViewModel: ObservableObject {
    
    internal static var shared: BottomSheetViewModel = BottomSheetViewModel()
    
    // Purchase status
    @Published internal var webCheckoutState: WebCheckoutState = .none
    
    @Published internal var hasActiveTransaction = false
    
    // Device Orientation
    @Published internal var orientation: Orientation = .portrait
    
    private init() {
        // Prevents Layout Warning Prints
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }
    
    // Resets the BottomSheet
    private func reset() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.webCheckoutState = .none
            TransactionViewModel.shared.reset()
        }
    }
    
    internal func setOrientation(orientation: Orientation) { self.orientation = orientation }
    
    // Reloads the purchase on failure screens
    internal func reload() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { TransactionViewModel.shared.buildTransaction() }
    }
    
    // Called when a user starts a product purchase
    internal func buildPurchase(product: Product, domain: String, metadata: String?, reference: String?) {
        self.hasActiveTransaction = true
        TransactionViewModel.shared.setUpTransaction(product: product, domain: domain, metadata: metadata, reference: reference)
        
        DispatchQueue(label: "build-transaction", qos: .userInteractive).async { self.initiateTransaction() }
    }
    
    internal func initiateTransaction() { TransactionViewModel.shared.buildTransaction() }
    
    // Handles the dismiss (click on the zone above the bottom sheet) for the multiple states of the bottom sheet
    internal func dismiss() {
        switch webCheckoutState {
        case .none: break
        case .inCheckout: self.userCancelled()
        case .failed: self.dismissVC()
        case .nointernet: self.dismissVC()
        }
    }
    
    // Dismiss Bottom Sheet
    private func dismissVC() {
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController,
           let presentedPurchaseVC = rootViewController.presentedViewController as? PurchaseViewController {
            
            var delay = 0.3
            if KeyboardObserver.shared.isKeyboardVisible { delay = 0.45 }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                presentedPurchaseVC.dismissPurchase()
                self.hasActiveTransaction = false
            }
        }
        
        self.reset() // Clear data related to finished purchase
    }
    
    internal func setWebCheckoutState(newState: WebCheckoutState) {
        DispatchQueue.main.async {
            if newState == .inCheckout {
                self.webCheckoutState = newState
            } else {
                self.webCheckoutState = newState
            }
        }
    }
    
    internal func userCancelled() {
        let result : TransactionResult = .userCancelled
        Utils.transactionResult(result: result)
        self.dismissVC()
    }
    
    internal func transactionFailedWith(error: AppCoinsSDKError, description: String? = nil) {
        switch error {
        case .networkError:
            let result: TransactionResult = .failed(error: error)
            Utils.transactionResult(result: result)
            DispatchQueue.main.async { self.webCheckoutState = .nointernet }
        default:
            let result: TransactionResult = .failed(error: error)
            Utils.transactionResult(result: result)
            DispatchQueue.main.async { self.webCheckoutState = .failed }
        }
    }
}
