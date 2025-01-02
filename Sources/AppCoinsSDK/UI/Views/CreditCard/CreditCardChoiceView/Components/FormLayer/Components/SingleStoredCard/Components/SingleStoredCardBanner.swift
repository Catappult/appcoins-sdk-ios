//
//  SingleStoredCardBanner.swift
//
//
//  Created by aptoide on 30/12/2024.
//

import SwiftUI
@_implementationOnly import Adyen

internal struct SingleStoredCardBanner: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    
    internal var paymentMethod: StoredCardPaymentMethod
    
    internal var body: some View {
        HStack(spacing: 0) {
            VStack{}.frame(width: 16)
            
            if let image = adyenController.getCardLogo(for: paymentMethod) {
                CreditCardAdyenIcon(image: image)
                    .animation(.easeIn(duration: 0.3))
            }
            
            VStack{}.frame(width: 16)
            
            Text(verbatim: "···· " + paymentMethod.lastFour)
                .foregroundColor(ColorsUi.APC_Black)
                .font(FontsUi.APC_Subheadline)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
        .background(ColorsUi.APC_White)
        .cornerRadius(10)
    }
}
