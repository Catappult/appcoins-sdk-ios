//
//  CreditCardChoiceViewButtonLayer.swift
//  
//
//  Created by aptoide on 30/12/2024.
//

import SwiftUI
@_implementationOnly import Adyen
@_implementationOnly import AdyenCard

internal struct CreditCardChoiceViewButtonLayer: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var adyenViewModel: AdyenViewModel = AdyenViewModel.shared
    
    @Binding internal var chosenStoredCard: StoredCardPaymentMethod?
    
    internal var body: some View {
        VStack(spacing: 0) {
            HStack{}.frame(maxHeight: .infinity)
            
            Button(action: { if let storedPaymentMethod = self.chosenStoredCard { adyenViewModel.payWithStoredCreditCard(creditCard: storedPaymentMethod) }}) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(transactionViewModel.transaction != nil ? ColorsUi.APC_Pink : ColorsUi.APC_Gray)
                    Text(Constants.buyText)
                }
            }
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .foregroundColor(ColorsUi.APC_White)
            
            VStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
        }
    }
}
