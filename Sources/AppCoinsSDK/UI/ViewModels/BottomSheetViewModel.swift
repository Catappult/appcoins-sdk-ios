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
    internal var discountPolicy: String? = nil
    internal var oemID: String? = nil
    
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
    internal var transactionUseCases: TransactionUseCases = TransactionUseCases.shared
    internal var walletUseCases: WalletUseCases = WalletUseCases.shared
    internal var currencyUseCases: CurrencyUseCases = CurrencyUseCases.shared
    
    // Device Orientation
    @Published internal var orientation: Orientation = .portrait
    
    // Keyboard Dismiss
    @Published internal var isKeyboardVisible: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    @Published internal var isPaymentMethodChoiceSheetPresented: Bool = false
        
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
            AuthViewModel.shared.reset()
            PayPalDirectViewModel.shared.reset()
            AdyenController.shared.reset()
        }
    }
    
    internal func presentPaymentMethodChoiceSheet() { self.isPaymentMethodChoiceSheetPresented = true }
        
    internal func dismissPaymentMethodChoiceSheet() { self.isPaymentMethodChoiceSheetPresented = false }
    
    internal func setOrientation(orientation: Orientation) { self.orientation = orientation }
    
    // Reloads the purchase on failure screens
    internal func reload() {
        DispatchQueue.main.async { self.purchaseState = .loading }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { TransactionViewModel.shared.buildTransaction() }
    }
    
    // Called when a user starts a product purchase
    internal func buildPurchase(product: Product, domain: String, metadata: String?, reference: String?, discountPolicy: String? = nil, oemID: String? = nil) {
        self.hasActiveTransaction = true
        self.product = product
        self.domain = domain
        self.metadata = metadata
        self.reference = reference
        self.discountPolicy = discountPolicy
        self.oemID = oemID
        
        TransactionViewModel.shared.setUpTransaction(product: product, domain: domain, metadata: metadata, reference: reference, discountPolicy: discountPolicy, oemID: oemID)
        
        DispatchQueue(label: "build-transaction", qos: .userInteractive).async { self.initiateTransaction() }
    }
    
    internal func initiateTransaction() { TransactionViewModel.shared.buildTransaction() }
    
    // Handles the dismiss (click on the zone above the bottom sheet) for the multiple states of the bottom sheet
    internal func dismiss() {
        switch purchaseState {
        case .none: break
        case .loading: self.userCancelled()
        case .paying: self.userCancelled()
        case .adyen:
            if AdyenController.shared.state != .none {
                AdyenController.shared.cancel()
                self.userCancelled()
            }
        case .login: 
            if self.hasCompletedPurchase() { self.transactionSucceeded() }
            else { self.userCancelled() }
        case .processing: break
        case .success: self.transactionSucceeded()
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
        
        if let paymentMethodSelected = TransactionViewModel.shared.paymentMethodSelected {
            DispatchQueue.main.async { self.purchaseState = .processing }
            
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
                    self.transactionFailedWith(error: .systemError(message: "Payment Method not available", description: "Tried to purchase with a Payment Method that is not available at BottomSheetViewModel.swift:buy"))
                }
            }
        } else {
            self.presentPaymentMethodChoiceSheet()
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
                                self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
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
        } else { self.transactionFailedWith(error: .systemError(message: "Failed to buy with Appc", description: "Missing required transaction parameters at BottomSheetViewModel.swift:buyWithAppc")) }
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
                                self.transactionFailedWith(error: .systemError(debugInfo: DebugInfo(message: message, description: description, request: request)))
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
        } else { self.transactionFailedWith(error: .systemError(message: "Failed to buy with Sandbox", description: "Missing required transaction parameters at BottomSheetViewModel.swift:buyWithSandbox")) }
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
                        if let moneyAmount = TransactionViewModel.shared.transactionParameters?.value, let moneyCurrrency = TransactionViewModel.shared.transactionParameters?.currency {
                            AdyenViewModel.shared.buyWithCreditCard(raw: raw, wallet: wallet, moneyAmount: moneyAmount, moneyCurrency: moneyCurrrency)
                        } else { self.transactionFailedWith(error: .systemError(message: "Failed to buy with Credit Card", description: "Unable to unwrap transaction at BottomSheetViewModel.swift:buyWithCreditCard")) }
                    case .failure(let error):
                        switch error {
                        case .failed(let message, let description, let request):
                            self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                        case .noInternet(let message, let description, let request):
                            self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                        }
                    }
                }
            case .failure(let error):
                switch error {
                case .failed(let message, let description, let request):
                    self.transactionFailedWith(error: .unknown(message: message, description: description))
                case .general(let message, let description, let request):
                    self.transactionFailedWith(error: .unknown(message: message, description: description))
                case .noBillingAgreement(let message, let description, let request):
                    self.transactionFailedWith(error: .unknown(message: message, description: description))
                case .noInternet(let message, let description, let request):
                    self.transactionFailedWith(error: .unknown(message: message, description: description))
                case .timeOut(let message, let description, let request):
                    self.transactionFailedWith(error: .unknown(message: message, description: description))
                }
            }
        } else { self.transactionFailedWith(error: .systemError(message: "Failed to buy with Credit Card", description: "Missing required transaction parameters at BottomSheetViewModel.swift:buyWithCreditCard")) }
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
                        if let moneyAmount = TransactionViewModel.shared.transactionParameters?.value, let moneyCurrrency = TransactionViewModel.shared.transactionParameters?.currency {
                            AdyenViewModel.shared.buyWithPayPalAdyen(raw: raw, wallet: wallet, moneyAmount: moneyAmount, moneyCurrency: moneyCurrrency)
                        } else { self.transactionFailedWith(error: .systemError(message: "Failed to buy with Paypal Adyen", description: "Unable to unwrap transaction at BottomSheetViewModel.swift:buyWithPayPalAdyen")) }
                    case .failure(let error):
                        switch error {
                        case .failed(let message, let description, let request):
                            self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                        case .noInternet(let message, let description, let request):
                            self.transactionFailedWith(error: .notEntitled(message: message, description: description, request: request))
                        }
                    }
                }
            case .failure(let error):
                switch error {
                case .failed(let message, let description, let request):
                    self.transactionFailedWith(error: .unknown(message: message, description: description))
                case .general(let message, let description, let request):
                    self.transactionFailedWith(error: .unknown(message: message, description: description))
                case .noBillingAgreement(let message, let description, let request):
                    self.transactionFailedWith(error: .unknown(message: message, description: description))
                case .noInternet(let message, let description, let request):
                    self.transactionFailedWith(error: .unknown(message: message, description: description))
                case .timeOut(let message, let description, let request):
                    self.transactionFailedWith(error: .unknown(message: message, description: description))
                }            }
        } else { self.transactionFailedWith(error: .systemError(message: "Failed to buy with Paypal Adyen", description: "Missing required transaction parameters at BottomSheetViewModel.swift:buyWithPayPalAdyen")) }
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
                } else { self.transactionFailedWith(error: .systemError(message: "Failed to buy with Paypal Direct", description: "Missing required transaction parameters at BottomSheetViewModel.swift:buyWithPayPalDirect")) }
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
                                                    self.setSuccessfulPurchase(purchase: purchase, balance: balance, method: method)
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
                        } else { self.transactionFailedWith(error: .systemError(message: "Failed to finish the purchase", description: "Missing required transaction purchase uid at BottomSheetViewModel.swift:finishPurchase")) }
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
    
    internal func setSuccessfulPurchase(purchase: Purchase, balance: Balance, method: Method) {
        DispatchQueue.main.async {
            self.finalWalletBalance = "\(balance.balanceCurrency.sign)\(String(format: "%.2f", floor(balance.balance*100)/100))"
            self.purchaseState = .success
            self.successfulPurchase = purchase
        }

        self.transactionUseCases.setLastPaymentMethod(paymentMethod: method)
        
        if case var .direct(transaction) = TransactionViewModel.shared.transaction {
            DispatchQueue.main.async { self.transactionSucceeded() }
        } else {
            if AuthViewModel.shared.isLoggedIn { DispatchQueue.main.async { self.transactionSucceeded() } }
        }
    }
    
    internal func hasCompletedPurchase() -> Bool { return self.successfulPurchase != nil }
    
    internal func transactionSucceeded() {
        if let successfulPurchase = self.successfulPurchase {
            let verificationResult: VerificationResult = .verified(purchase: successfulPurchase)
            let purchaseResult: PurchaseResult = .success(verificationResult: verificationResult)
            Utils.purchaseResult(result: purchaseResult)

            if case var .direct(transaction) = TransactionViewModel.shared.transaction {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { self.dismissSuccessWithAnimation() }
            } else {
                if AuthViewModel.shared.isLoggedIn {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { self.dismissSuccessWithAnimation() }
                } else {
                    self.dismissVC()
                }
            }
        } else {
            self.transactionFailedWith(error: .systemError(message: "Failed to set transaction success", description: "Missing required transaction purchase BottomSheetViewModel.swift:transactionSucceeded"))
        }
    }
    
    internal func transactionFailedWith(error: AppCoinsSDKError, description: String? = nil) {
        if let description = description { DispatchQueue.main.async { self.purchaseFailedMessage = description } }
        switch error {
        case .networkError(let debugInfo):
            let result : PurchaseResult = .failed(error: error)
            Utils.purchaseResult(result: result)
            DispatchQueue.main.async { self.purchaseState = .nointernet }
        default:
            let result : PurchaseResult = .failed(error: error)
            Utils.purchaseResult(result: result)
            DispatchQueue.main.async { self.purchaseState = .failed }
        }
    }
    
    internal func userCancelled() {
        let result : PurchaseResult = .userCancelled
        Utils.purchaseResult(result: result)
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
}
