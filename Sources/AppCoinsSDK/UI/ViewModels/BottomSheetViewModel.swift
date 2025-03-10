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
    
    // Purchase attributes
    internal var product: Product? = nil
    internal var domain: String? = nil
    internal var metadata: String? = nil
    internal var reference: String? = nil
    
    // Purchase status
    @Published internal var purchaseState: PurchaseState = .none
    @Published internal var successfulPurchase: Purchase?
    
    // Variables used for BottomSheet animations on changing states
    @Published internal var isBottomSheetPresented = false
    @Published internal var isInitialSyncSheetPresented = false
    @Published internal var successAnimation: Bool = true
    @Published internal var successSyncAnimation: Bool = false
    
    // Variables used for BottomSheet text variable displays
    @Published internal var finalWalletBalance: String?
    @Published internal var purchaseFailedMessage: String = Constants.somethingWentWrong
    
    internal var hasActiveTransaction = false
    
    internal var productUseCases: ProductUseCases = ProductUseCases.shared
    internal var walletUseCases: WalletUseCases = WalletUseCases.shared
    internal var currencyUseCases: CurrencyUseCases = CurrencyUseCases.shared
    
    // Device Orientation
    @Published internal var orientation: Orientation = .portrait
    
    // Keyboard Dismiss
    @Published internal var isKeyboardVisible: Bool = false
    private var cancellables = Set<AnyCancellable>()
        
    private init() {
        // Prevents Layout Warning Prints
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] _ in
                self?.isKeyboardVisible = true
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.isKeyboardVisible = false
            }
            .store(in: &cancellables)
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    // Resets the BottomSheet
    private func reset() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.purchaseState = .loading
            self.successfulPurchase = nil
            self.finalWalletBalance = nil
            self.purchaseFailedMessage = Constants.somethingWentWrong
            
            TransactionViewModel.shared.reset()
        }
    }
    
    internal func setOrientation(orientation: Orientation) { self.orientation = orientation }
    
    // Reloads the purchase on failure screens
    internal func reload() {
        DispatchQueue.main.async { self.purchaseState = .loading }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { TransactionViewModel.shared.buildTransaction() }
    }
    
    // Called when a user starts a product purchase
    internal func buildPurchase(product: Product, domain: String, metadata: String?, reference: String?) {
        self.hasActiveTransaction = true
        self.product = product
        self.domain = domain
        self.metadata = metadata
        self.reference = reference
        TransactionViewModel.shared.setUpTransaction(product: product, domain: domain, metadata: metadata, reference: reference)
        
        DispatchQueue(label: "build-transaction", qos: .userInteractive).async { self.initiateTransaction() }
    }
    
    internal func initiateTransaction() { TransactionViewModel.shared.buildTransaction() }
    
    // Handles the dismiss (click on the zone above the bottom sheet) for the multiple states of the bottom sheet
    internal func dismiss() {
        switch purchaseState {
        case .none: break
        case .loading: self.userCancelled()
        case .paying: self.userCancelled()
        case .processing: break
        case .login: break
        case .adyen: break
        case .success: break
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
    
    internal func setPurchaseState(newState: PurchaseState) { DispatchQueue.main.async { self.purchaseState = newState } }
    
    internal func userCancelled() {
        let result : TransactionResult = .userCancelled
        Utils.transactionResult(result: result)
        self.dismissVC()
    }
    
    internal func transactionFailedWith(error: AppCoinsSDKError, description: String? = nil) {
        if let description = description { DispatchQueue.main.async { self.purchaseFailedMessage = description } }
        switch error {
        case .networkError:
            let result : TransactionResult = .failed(error: error)
            Utils.transactionResult(result: result)
            DispatchQueue.main.async { self.purchaseState = .nointernet }
        default:
            let result : TransactionResult = .failed(error: error)
            Utils.transactionResult(result: result)
            DispatchQueue.main.async { self.purchaseState = .failed }
        }
    }
}
