//
//  BottomSheetViewModel.swift
//
//
//  Created by aptoide on 08/03/2023.
//

import Foundation
import SwiftUI

internal class BottomSheetViewModel : ObservableObject {
    
    internal static var shared : BottomSheetViewModel = BottomSheetViewModel()
    
    // Purchase attributes
    internal var product: Product? = nil
    internal var domain: String? = nil
    internal var metadata: String? = nil
    internal var reference: String? = nil
    
    // The purchase resulting from the completed transaction, used for when there's a sync or an install after the purchase has been completed
    private var purchase: Purchase? = nil
    private var purchaseCompleted: Bool = false
    
    // Purchase status
    @Published internal var purchaseState: PurchaseState = .none
    @Published internal var walletSyncingStatus: WalletSyncingStatus = .none
    
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
    internal var transactionUseCases: TransactionUseCases = TransactionUseCases.shared
    internal var walletUseCases: WalletUseCases = WalletUseCases.shared
    internal var walletApplicationUseCases: WalletApplicationUseCases = WalletApplicationUseCases.shared
    internal var currencyUseCases: CurrencyUseCases = CurrencyUseCases.shared
    
    private init() { UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable") } // Prevents Layout Warning Prints
    
    // Resets the BottomSheet
    private func reset() {
        DispatchQueue.main.async {
            self.purchase = nil
            self.purchaseCompleted = false
            
            self.purchaseState = .paying
            self.finalWalletBalance = nil
            self.purchaseFailedMessage = Constants.somethingWentWrong
            
            TransactionViewModel.shared.reset()
            PayPalDirectViewModel.shared.reset()
            AdyenController.shared.reset()
        }
    }
    
    // Reloads the purchase on failure screens
    internal func reload() {
        DispatchQueue.main.async { self.purchaseState = .paying }
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
    
    internal func initiateTransaction() {
        walletApplicationUseCases.isWalletAvailable() {
            walletAvailable in
            
            if walletAvailable && self.walletApplicationUseCases.isWalletInstalled() {
                let newWalletSyncingStatus = self.walletUseCases.getWalletSyncingStatus()
                DispatchQueue.main.async { self.walletSyncingStatus = newWalletSyncingStatus }
                
                switch newWalletSyncingStatus {
                case .accepted: TransactionViewModel.shared.buildTransaction()
                case .rejected: TransactionViewModel.shared.buildTransaction()
                case .none: DispatchQueue.main.async { self.purchaseState = .initialAskForSync }
                }
            } else {
                if [.accepted, .rejected].contains(self.walletUseCases.getWalletSyncingStatus()) { self.walletUseCases.updateWalletSyncingStatus(status: .none) }
                DispatchQueue.main.async { self.walletSyncingStatus = .none }
                TransactionViewModel.shared.buildTransaction()
            }
        }
    }
    
    // Handles the dismiss (click on the zone above the bottom sheet) for the multiple states of the bottom sheet
    func dismiss() {
        switch purchaseState {
        case .none: break
        case .initialAskForSync: self.userCancelled()
        case .syncProcessing: break
        case .syncSuccess: if hasCompletedPurchase() { self.skipWalletSync() } else { break }
        case .syncError: if hasCompletedPurchase() { self.skipWalletSync() } else { break }
        case .paying: self.userCancelled()
        case .adyen:
            if AdyenController.shared.state != .none {
                AdyenController.shared.cancel()
                self.userCancelled()
            }
        case .processing: break
        case .success: self.dismissVC()
        case .successAskForInstall: self.skipWalletInstall()
        case .successAskForSync: self.skipWalletSync()
        case .failed: self.dismissVC()
        case .nointernet: self.dismissVC()
        }
    }
    
    // Dismiss Bottom Sheet
    private func dismissVC() {
        if KeyboardObserver.shared.isKeyboardVisible {
            AdyenController.shared.presentableComponent?.viewController.view.findAndResignFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { withAnimation { self.isBottomSheetPresented = false } }
        } else if !(self.purchaseState == .adyen && AdyenController.shared.state == .storedCreditCard) {
            DispatchQueue.main.async { withAnimation { self.isBottomSheetPresented = false } }
        }
        
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
    
    // User presses buy button
    internal func buy() {
        
        AnalyticsUseCases.shared.recordPurchaseIntent(paymentMethod: TransactionViewModel.shared.paymentMethodSelected?.name ?? "")
        
        DispatchQueue(label: "buy-item", qos: .userInteractive).async {
            switch TransactionViewModel.shared.paymentMethodSelected?.name {
            case Method.appc.rawValue:
                DispatchQueue.main.async { self.purchaseState = .processing }
                self.buyWithAppc()
            case Method.creditCard.rawValue:
                DispatchQueue.main.async { self.purchaseState = .adyen }
                self.buyWithCreditCard()
            case Method.paypalAdyen.rawValue:
                DispatchQueue.main.async { self.purchaseState = .processing }
                self.buyWithPayPalAdyen()
            case Method.paypalDirect.rawValue:
                DispatchQueue.main.async { self.purchaseState = .processing }
                self.buyWithPayPalDirect()
            case Method.sandbox.rawValue:
                DispatchQueue.main.async { self.purchaseState = .processing }
                self.buyWithSandbox()
            default:
                self.transactionFailedWith(error: .systemError(message: "Payment Method not available.", description: "Tried to purchase with a Payment Method that is not available."))
            }
        }
    }
    
    internal func buyWithAppc() {
        if let parameters = TransactionViewModel.shared.transactionParameters {
            let raw = CreateAPPCTransactionRaw.fromParameters(parameters: parameters)
            
            self.walletUseCases.getWallet() {
                result in
                
                switch result {
                case .success(let wallet):
                    self.transactionUseCases.createAPPCTransaction(wa: wallet, raw: raw) {
                        result in
                        
                        switch result {
                        case .success(let transactionResponse):
                            self.finishPurchase(transactionUuid: transactionResponse.uuid, method: .appc)
                        case .failure(let error):
                            switch error {
                            case .failed(let message, let description, let request):
                                self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)), description: description)
                            case .general(let message, let description, let request):
                                self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                            case .noBillingAgreement(let message, let description, let request):
                                self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                            case .noInternet(let message, let description, let request):
                                self.transactionFailedWith(error: .networkError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                            case .timeOut(let message, let description, let request):
                                self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                            }
                        }
                    }
                case .failure(let error):
                    switch error {
                    case .failed(let message, let description, let request):
                        self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                    case .noInternet(let message, let description, let request):
                        self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                    }
                }
            }
        } else { self.transactionFailedWith(error: .systemError(message: "buyWithAppc method Failed", description: "Missing required transaction parameters")) }
    }
    
    internal func buyWithSandbox() {
        if let parameters = TransactionViewModel.shared.transactionParameters {
            let raw = CreateSandboxTransactionRaw.fromParameters(parameters: parameters)
            
            self.walletUseCases.getWallet() {
                result in
                
                switch result {
                case .success(let wallet):
                    self.transactionUseCases.createSandboxTransaction(wa: wallet, raw: raw) {
                        result in
                        
                        switch result {
                        case .success(let transactionResponse):
                            self.finishPurchase(transactionUuid: transactionResponse.uuid, method: .sandbox)
                        case .failure(let error):
                            switch error {
                            case .failed(let message, let description, let request):
                                self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)), description: description)
                            case .general(let message, let description, let request):
                                self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                            case .noBillingAgreement(let message, let description, let request):
                                self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                            case .noInternet(let message, let description, let request):
                                self.transactionFailedWith(error: .networkError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                            case .timeOut(let message, let description, let request):
                                self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                            }
                        }
                    }
                case .failure(let error):
                    switch error {
                    case .failed(let message, let description, let request):
                        self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                    case .noInternet(let message, let description, let request):
                        self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                    }
                }
            }
        } else { self.transactionFailedWith(error: .systemError(message: "buyWithSandbox method Failed", description: "Missing required transaction parameters")) }
    }
    
    internal func buyWithCreditCard() {
        TransactionViewModel.shared.transactionParameters?.setMethod(method: Method.creditCard)
        if let parameters = TransactionViewModel.shared.transactionParameters {
            let raw = CreateAdyenTransactionRaw.fromParameters(parameters: parameters)
            switch raw {
            case .success(let raw):
                self.walletUseCases.getWallet() {
                    result in
                    
                    switch result {
                    case .success(let wallet):
                        if let moneyAmount = TransactionViewModel.shared.transaction?.moneyAmount, let moneyCurrrency = TransactionViewModel.shared.transaction?.moneyCurrency {
                            AdyenViewModel.shared.buyWithCreditCard(raw: raw, wallet: wallet, moneyAmount: moneyAmount, moneyCurrency: moneyCurrrency)
                        } else { self.transactionFailedWith(error: .systemError(message: "Buy With Credit Card Failed", description: "Unable to unwrap transaction")) }
                    case .failure(let error):
                        switch error {
                        case .failed(let message, let description, let request):
                            self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                        case .noInternet(let message, let description, let request):
                            self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                        }
                    }
                }
            case .failure(_): self.transactionFailedWith(error: .unknown(message: "Unknown", description: "Unknown"))
            }
        } else { self.transactionFailedWith(error: .systemError(message: "buyWithCreditCard method Failed", description: "Missing required transaction parameters")) }
    }
    
    internal func buyWithPayPalAdyen() {
        TransactionViewModel.shared.transactionParameters?.setMethod(method: Method.paypalAdyen)
        if let parameters = TransactionViewModel.shared.transactionParameters {
            let raw = CreateAdyenTransactionRaw.fromParameters(parameters: parameters)
            switch raw {
            case .success(let raw):
                self.walletUseCases.getWallet() {
                    result in
                    
                    switch result {
                    case .success(let wallet):
                        if let moneyAmount = TransactionViewModel.shared.transaction?.moneyAmount, let moneyCurrrency = TransactionViewModel.shared.transaction?.moneyCurrency {
                            AdyenViewModel.shared.buyWithPayPalAdyen(raw: raw, wallet: wallet, moneyAmount: moneyAmount, moneyCurrency: moneyCurrrency)
                        } else { self.transactionFailedWith(error: .systemError(message: "Buy With Paypal Adyen Failed", description: "Unable to unwrap transaction")) }
                    case .failure(let error):
                        switch error {
                        case .failed(let message, let description, let request):
                            self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                        case .noInternet(let message, let description, let request):
                            self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                        }
                    }
                }
            case .failure(_): self.transactionFailedWith(error: .unknown(message: "Unknown", description: "Unknown"))
            }
        } else { self.transactionFailedWith(error: .systemError(message: "buyWithPaypalAdyen method Failed", description: "Missing required transaction parameters")) }
    }
    
    internal func buyWithPayPalDirect() {
        self.walletUseCases.getWallet() {
            result in
            
            switch result {
            case .success(let wallet):
                if let parameters = TransactionViewModel.shared.transactionParameters {
                    let raw = CreateBAPayPalTransactionRaw.fromParameters(parameters: parameters)
                    PayPalDirectViewModel.shared.buyWithPayPalDirect(raw: raw, wallet: wallet) {
                        result in
                        
                        switch result {
                        case .success(let uuid):
                            self.finishPurchase(transactionUuid: uuid, method: .paypalDirect)
                        case .failure(let error):
                            switch error {
                            case .failed(let message, let description, let request):
                                self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)), description: description)
                            case .general(let message, let description, let request):
                                self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                            case .noBillingAgreement(let message, let description, let request):
                                self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                            case .noInternet(let message, let description, let request):
                                self.transactionFailedWith(error: .networkError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                            case .timeOut(let message, let description, let request):
                                self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                            }
                        }
                    }
                } else { self.transactionFailedWith(error: .systemError(message: "buyWithPaypalDirect method Failed", description: "Missing required transaction parameters")) }
            case .failure(let error):
                switch error {
                case .failed(let message, let description, let request):
                    self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                case .noInternet(let message, let description, let request):
                    self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                }
            }
        }
    }
    
    internal func finishPurchase(transactionUuid: String, method: Method) {
        self.walletUseCases.getWallet() {
            result in
            
            switch result {
            case .success(let wallet):
                self.transactionUseCases.getTransactionInfo(uid: transactionUuid, wa: wallet) {
                    result in
                    
                    switch result {
                    case .success(let transaction):
                        if let purchaseUID = transaction.purchaseUID {
                            wallet.getBalance {
                                result in
                                switch result {
                                case .success(let balance):
                                    Purchase.verify(domain: transaction.domain ,purchaseUID: purchaseUID) {
                                        result in
                                        switch result {
                                        case .success(let purchase):
                                            purchase.acknowledge(domain: transaction.domain) {
                                                error in
                                                if let error = error { self.transactionFailedWith(error: error) }
                                                else {
                                                    self.successfulTransaction(purchase: purchase, balance: balance, method: method)
                                                }
                                            }
                                        case .failure(let error): self.transactionFailedWith(error: error)
                                        }
                                    }
                                case .failure(let error):
                                    switch error {
                                    case .failed(let message, let description, let request):
                                        self.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
                                    case .noInternet(let message, let description, let request):
                                        self.transactionFailedWith(error: .networkError(message: message, description: description, request: request))
                                    }
                                }
                            }
                        } else { self.transactionFailedWith(error: .systemError(message: "finishPurchase method Failed", description: "Missing required transaction purchase uid")) }
                    case .failure(let error):
                        switch error {
                        case .failed(let message, let description, let request):
                            self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)), description: description)
                        case .general(let message, let description, let request):
                            self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                        case .noBillingAgreement(let message, let description, let request):
                            self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                        case .noInternet(let message, let description, let request):
                            self.transactionFailedWith(error: .networkError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                        case .timeOut(let message, let description, let request):
                            self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
                        }
                    }
                }
            case .failure(let error):
                switch error {
                case .failed(let message, let description, let request):
                    self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                case .noInternet(let message, let description, let request):
                    self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                }
            }
        }
    }
    
    internal func setPurchaseState(newState: PurchaseState) { DispatchQueue.main.async { self.purchaseState = newState } }
    
    internal func successfulTransaction(purchase: Purchase, balance: Balance, method: Method) {
        walletApplicationUseCases.isWalletAvailable() {
            walletAvailable in
            
            if !walletAvailable || self.walletUseCases.getWalletSyncingStatus() == .accepted {
                DispatchQueue.main.async {
                    self.finalWalletBalance = "\(balance.balanceCurrency.sign)\(String(format: "%.2f", balance.balance))"
                    self.purchaseState = .success
                }
                
                let verificationResult: VerificationResult = .verified(purchase: purchase)
                let transactionResult: TransactionResult = .success(verificationResult: verificationResult)
                Utils.transactionResult(result: transactionResult)
                
                self.transactionUseCases.setLastPaymentMethod(paymentMethod: method)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { self.dismissSuccessWithAnimation() }
            } else {
                if self.walletApplicationUseCases.isWalletInstalled() {
                    DispatchQueue.main.async { self.purchaseState = .successAskForSync }
                } else {
                    DispatchQueue.main.async { self.purchaseState = .successAskForInstall }
                }
                
                self.purchase = purchase
                self.purchaseCompleted = true
                self.transactionUseCases.setLastPaymentMethod(paymentMethod: method)
            }
        }
    }
    
    internal func transactionFailedWith(error: AppCoinsSDKError, description: String? = nil) {
        if let description = description { DispatchQueue.main.async { self.purchaseFailedMessage = description } }
        switch error {
        case .networkError(let debugInfo):
            let result : TransactionResult = .failed(error: error)
            Utils.transactionResult(result: result)
            DispatchQueue.main.async { self.purchaseState = .nointernet }
        default:
            let result : TransactionResult = .failed(error: error)
            Utils.transactionResult(result: result)
            DispatchQueue.main.async { self.purchaseState = .failed }
        }
    }
    
    internal func userCancelled() {
        let result : TransactionResult = .userCancelled
        Utils.transactionResult(result: result)
        self.dismissVC()
    }
    
    internal func dismissSuccessWithAnimation() {
        if purchaseState == .success { DispatchQueue.main.async { withAnimation { self.successAnimation = false } } }
        else { DispatchQueue.main.async { withAnimation { self.successSyncAnimation = false } } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.purchaseState == .success { DispatchQueue.main.async { withAnimation { self.successAnimation = true } } }
            self.dismissVC()
        }
    }
    
    internal func skipWalletInstall() {
        if hasCompletedPurchase(), let purchase = purchase {
            let verificationResult: VerificationResult = .verified(purchase: purchase)
            let transactionResult: TransactionResult = .success(verificationResult: verificationResult)
            Utils.transactionResult(result: transactionResult)
            dismissSuccessWithAnimation()
        } else {
            self.transactionFailedWith(error: .systemError(message: "skipWalletInstall method Failed", description: "Missing required parameters: purchase is nil or hasCompletedPurhcase is false"))
        }
    }
    
    internal func skipWalletSync() {
        DispatchQueue(label: "update-wallet-syncing-status", qos: .utility).async {
            if self.walletUseCases.getWalletSyncingStatus() == .none {
                self.walletUseCases.updateWalletSyncingStatus(status: .rejected)
            }
        }
        
        if hasCompletedPurchase(), let purchase = purchase {
            let verificationResult: VerificationResult = .verified(purchase: purchase)
            let transactionResult: TransactionResult = .success(verificationResult: verificationResult)
            Utils.transactionResult(result: transactionResult)
            dismissSuccessWithAnimation()
        } else {
            DispatchQueue.main.async { withAnimation { self.isInitialSyncSheetPresented = false } }
            DispatchQueue(label: "build-transaction", qos: .userInteractive).asyncAfter(deadline: .now() + 0.5) { TransactionViewModel.shared.buildTransaction() }
        }
    }
    
    internal func hasCompletedPurchase() -> Bool { return purchaseCompleted }
    
}
