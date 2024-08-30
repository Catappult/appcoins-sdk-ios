//
//  AdyenViewModel.swift
//  
//
//  Created by aptoide on 18/10/2023.
//

import Foundation
import Adyen

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
                case .failed(let description):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError, description: description)
                case .noInternet:
                    self.bottomSheetViewModel.transactionFailedWith(error: .networkError)
                default:
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError)
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
                case .failed(let description):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError, description: description)
                case .noInternet:
                    self.bottomSheetViewModel.transactionFailedWith(error: .networkError)
                default:
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError)
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

    internal func adyenFailedHandler() {
        bottomSheetViewModel.transactionFailedWith(error: .systemError)
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
