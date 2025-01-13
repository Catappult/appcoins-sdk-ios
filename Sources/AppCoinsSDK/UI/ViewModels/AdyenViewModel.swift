//
//  AdyenViewModel.swift
//  
//
//  Created by aptoide on 18/10/2023.
//

import Foundation
@_implementationOnly import Adyen

// Helper to the BottomSheetViewModel
internal class AdyenViewModel : ObservableObject {
    
    internal static var shared : AdyenViewModel = AdyenViewModel()
    
    internal var transactionUseCases: TransactionUseCases = TransactionUseCases.shared
    internal var bottomSheetViewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    private init() {}
    
    internal func buyWithCreditCard(raw: CreateAdyenTransactionRaw, wallet: Wallet, moneyAmount: Double, moneyCurrency: Currency) {
        self.transactionUseCases.createAdyenTransaction(wa: wallet, raw: raw) {
            result in
            
            switch result {
            case .success(let session):
                AdyenController.shared.startSession(method: Method.creditCard, value: Decimal(moneyAmount), currency: moneyCurrency.currency, session: session, successHandler: self.adyenSuccessHandler, awaitHandler: self.adyenFailedHandler, failedHandler: self.adyenFailedHandler, cancelHandler: self.adyenCancelHandler)
            case .failure(let error):
                switch error {
                case .failed(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request), description: description)
                case .general(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
                case .noBillingAgreement(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
                case .noInternet(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .networkError(message: message, description: description, request: request))
                case .timeOut(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
                }
            }
        }
    }
    
    internal func buyWithPayPalAdyen(raw: CreateAdyenTransactionRaw, wallet: Wallet, moneyAmount: Double, moneyCurrency: Currency) {
        self.transactionUseCases.createAdyenTransaction(wa: wallet, raw: raw) {
            result in
            
            switch result {
            case .success(let session):
                AdyenController.shared.startSession(method: Method.paypalAdyen, value: Decimal(moneyAmount), currency: moneyCurrency.currency, session: session, successHandler: self.adyenSuccessHandler, awaitHandler: self.adyenFailedHandler, failedHandler: self.adyenFailedHandler, cancelHandler: self.adyenCancelHandler)
            case .failure(let error):
                switch error {
                case .failed(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request), description: description)
                case .general(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
                case .noBillingAgreement(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
                case .noInternet(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .networkError(message: message, description: description, request: request))
                case .timeOut(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
                }
            }
        }
    }
    
    internal func adyenSuccessHandler(method: Method, transactionUID: String) {
        DispatchQueue.main.async {
            self.bottomSheetViewModel.setPurchaseState(newState: .processing)
            self.bottomSheetViewModel.finishPurchase(transactionUuid: transactionUID, method: method)
        }
    }

    internal func adyenFailedHandler(message: String, description: String) {
        self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description)) // "Failed to start a buy session"
    }
    
    internal func adyenCancelHandler() {
        bottomSheetViewModel.userCancelled()
    }
    
    internal func payWithStoredCreditCard(creditCard: StoredCardPaymentMethod) {
        AdyenController.shared.chooseStoredCreditCardPayment(paymentMethod: creditCard)
    }
    
    internal func payWithNewCreditCard() {
        AdyenController.shared.chooseNewCreditCardPayment()
    }
}
