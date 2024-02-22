//
//  PayPalDirectViewModel.swift
//  
//
//  Created by aptoide on 18/10/2023.
//

import Foundation
import PPRiskMagnes

// Helper to the BottomSheetViewModel
internal class PayPalDirectViewModel : ObservableObject {
    
    internal static var shared : PayPalDirectViewModel = PayPalDirectViewModel()
    
    internal var transactionUseCases: TransactionUseCases = TransactionUseCases.shared
    internal var walletUseCases: WalletUseCases = WalletUseCases.shared
    internal var bottomSheetViewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    @Published internal var presentPayPalSheet : Bool = false
    @Published internal var presentPayPalSheetURL : URL? = nil
    @Published internal var presentPayPalSheetMethod : String? = nil
    @Published internal var userDismissPayPalSheet : Bool = true
    
    internal var raw : CreateBAPayPalTransactionRaw?
    
    private init() {}
    
    // Reset the PayPal handler variables
    // Usually done between different purchases
    internal func reset() {
        self.presentPayPalSheet = false
        self.presentPayPalSheetURL = nil
        self.presentPayPalSheetMethod = nil
        self.userDismissPayPalSheet = true
    }
    
    // Buy action, processes a transaction with two possible options:
    // 1. If the user has a Billing Agreement: processes the transaction directly
    // 2. If the user does not have a Billing Agreement: prompts the PayPal WebView for the user to create a BA
    internal func buyWithPayPalDirect(raw: CreateBAPayPalTransactionRaw, wallet: Wallet, completion: @escaping (Result<String, TransactionError>) -> Void) {
        self.raw = raw
        
        let magnesSDK = MagnesSDK.shared()
        try? magnesSDK.setUp()
        
        self.transactionUseCases.createBAPayPalTransaction(wa: wallet, raw: raw) {
            result in
            
            switch result {
            case .success(let transactionResponse):
                completion(.success(transactionResponse.uuid))
            case .failure(let error):
                switch error {
                case .noBillingAgreement:
                    self.transactionUseCases.createBillingAgreementToken() {
                        result in
                        
                        switch result {
                        case .success(let response):
                            if let redirectURL = URL(string: response.redirect.url) {
                                DispatchQueue.main.async {
                                    self.presentPayPalSheetURL = redirectURL
                                    self.presentPayPalSheetMethod = response.redirect.method
                                    self.presentPayPalSheet = true
                                    self.userDismissPayPalSheet = true
                                }
                            } else { completion(.failure(.failed())) }
                        case .failure(let error): completion(.failure(error))
                        }
                    }
                default: completion(.failure(error))
                }
            }
        }
    }
    
    // Cancels a user Billing Agreement
    internal func logoutPayPal() {
        DispatchQueue(label: "logout-paypal", qos: .userInteractive).async {
            self.transactionUseCases.cancelBillingAgreement() { result in }
        }
        transactionViewModel.showPaymentMethodOptions()
    }
    
    // Dismisses the PayPal WebView
    internal func dismissPayPalView() {
        // Only apply when it is the user dismissing the view
        if userDismissPayPalSheet {
            DispatchQueue.main.async {
                self.presentPayPalSheet = false
                self.bottomSheetViewModel.userCancelled()
            }
        }
    }
    
    // User cancelled the transaction on the PayPal WebView, the token used to create the Billing Agreement is cancelled as is the whole transaction
    internal func cancelBillingAgreementTokenPayPal(token: String?) {
        DispatchQueue.main.async {
            self.userDismissPayPalSheet = false
            self.presentPayPalSheet = false
        }
        
        if let token = token {
            self.transactionUseCases.cancelBillingAgreementToken(token: token) {
                result in
                DispatchQueue.main.async {
                    self.presentPayPalSheet = false
                    self.bottomSheetViewModel.userCancelled()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.presentPayPalSheet = false
                self.bottomSheetViewModel.userCancelled()
            }
        }
    }
    
    // Creates a Billing Agreement with the information coming from the PayPal WebView and tries to process the transaction again
    internal func createBillingAgreementAndFinishTransaction(token: String) {
        DispatchQueue.main.async {
            self.userDismissPayPalSheet = false
            self.presentPayPalSheet = false
        }
        
        self.transactionUseCases.createBillingAgreement(token: token) {
            result in
            
            switch result {
            case .success(_):
                if let raw = self.raw, let wallet = self.walletUseCases.getClientWallet() {
                    self.buyWithPayPalDirect(raw: raw, wallet: wallet) {
                        result in
                        switch result {
                        case .success(let uuid): self.bottomSheetViewModel.finishPurchase(transactionUuid: uuid, method: .paypalDirect)
                            case .failure(let error):
                                switch error {
                                case .failed(let description): self.bottomSheetViewModel.transactionFailedWith(error: .systemError, description: description)
                                case .noInternet: self.bottomSheetViewModel.transactionFailedWith(error: .networkError)
                                default: self.bottomSheetViewModel.transactionFailedWith(error: .systemError)
                            }
                        }
                    }
                } else { self.bottomSheetViewModel.transactionFailedWith(error: .notEntitled) }
            case .failure(let error):
                switch error {
                case .failed(_): self.bottomSheetViewModel.transactionFailedWith(error: .systemError)
                case .noInternet: self.bottomSheetViewModel.transactionFailedWith(error: .networkError)
                default: self.bottomSheetViewModel.transactionFailedWith(error: .systemError)
                }
            }
        }
    }
    
}
