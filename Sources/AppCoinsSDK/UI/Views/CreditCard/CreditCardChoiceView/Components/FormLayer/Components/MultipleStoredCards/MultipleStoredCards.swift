//
//  MultipleStoredCards.swift
//
//
//  Created by Graciano Caldeira on 18/10/2024.
//

import SwiftUI
@_implementationOnly import Adyen

internal struct MultipleStoredCards: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    
    @Binding internal var chosenStoredCard: StoredCardPaymentMethod?
    internal var storedPaymentMethods: [any StoredPaymentMethod]
    
    internal var body: some View {
        Text(Constants.chooseCard)
            .font(FontsUi.APC_Body_Bold)
            .foregroundColor(ColorsUi.APC_Black)
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 20, alignment: .leading)
        
        VStack{}.frame(height: 10)
        
        VStack(spacing: 0) {
            ForEach(0 ..< storedPaymentMethods.count, id: \.self) { paymentMethodNumber in
                if let paymentMethod = storedPaymentMethods[paymentMethodNumber] as? StoredCardPaymentMethod {
                    StoredCardsListElement(paymentMethod: paymentMethod, chosenStoredCard: self.$chosenStoredCard)
                }
                
                if paymentMethodNumber < storedPaymentMethods.count - 1 {
                    Divider().background(ColorsUi.APC_Gray)
                }
            }
        }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48)
            .cornerRadius(13)
    }
}
