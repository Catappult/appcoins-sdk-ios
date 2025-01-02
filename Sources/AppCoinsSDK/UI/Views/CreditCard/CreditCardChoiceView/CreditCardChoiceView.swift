//
//  CreditCardChoiceBottomSheet.swift
//
//
//  Created by aptoide on 29/08/2023.
//

import SwiftUI
@_implementationOnly import Adyen
@_implementationOnly import AdyenCard

internal struct CreditCardChoiceView: View {
    
    @State internal var chosenStoredCard: StoredCardPaymentMethod?
    
    internal init() {
        if let firstStoredCard = AdyenController.shared.session?.sessionContext.paymentMethods.stored.first as? StoredCardPaymentMethod {
            // Only way to initialize a State variable on init method: https://stackoverflow.com/a/58137096/18917552
            _chosenStoredCard = State(initialValue: firstStoredCard)
        }
    }
    
    internal var body: some View {
        ZStack {
            CreditCardChoiceViewFormLayer(chosenStoredCard: self.$chosenStoredCard)
            CreditCardChoiceViewButtonLayer(chosenStoredCard: self.$chosenStoredCard)
        }.frame(maxHeight: .infinity, alignment: .bottom)
    }
}
