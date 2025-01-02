//
//  CreditCardChoiceViewFormLayer.swift
//  
//
//  Created by aptoide on 30/12/2024.
//

import SwiftUI
@_implementationOnly import Adyen
@_implementationOnly import AdyenCard

internal struct CreditCardChoiceViewFormLayer: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var adyenViewModel: AdyenViewModel = AdyenViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    @Binding internal var chosenStoredCard: StoredCardPaymentMethod?
    
    internal var body: some View {
        VStack(spacing: 0) {
            if let storedPaymentMethods = adyenController.session?.sessionContext.paymentMethods.stored {
                OverflowAnimationWrapper(height: viewModel.orientation == .landscape ? (UIScreen.main.bounds.height * 0.9) - 78 - 72 : 420 - 78 - 72, offset: 72) {
                    VStack(spacing: 0) {
                        PurchaseBonusBanner(viewModel: viewModel, transactionViewModel: transactionViewModel, authViewModel: authViewModel)
                        
                        VStack{}.frame(height: 16)
                        
                        if storedPaymentMethods.count == 1, let paymentMethod = storedPaymentMethods.first as? StoredCardPaymentMethod {
                            SingleStoredCard(paymentMethod: paymentMethod)
                        } else {
                            MultipleStoredCards(chosenStoredCard: $chosenStoredCard, storedPaymentMethods: storedPaymentMethods)
                        }
                        
                        VStack{}.frame(height: 8)
                        
                        Button(action: adyenViewModel.payWithNewCreditCard) {
                            Text(Constants.addCard)
                                .foregroundColor(ColorsUi.APC_Pink)
                                .font(FontsUi.APC_Footnote_Bold)
                                .lineLimit(1)
                        }
                        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 18, alignment: .trailing)
                    }.ignoresSafeArea(.all)
                }
                
                HStack{}.frame(height: 78)
            }
        }
    }
}
