//
//  SingleStoredCard.swift
//
//
//  Created by Graciano Caldeira on 18/10/2024.
//

import SwiftUI
@_implementationOnly import Adyen

internal struct SingleStoredCard: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    
    internal var paymentMethod: StoredCardPaymentMethod
    
    internal var body: some View {
        Text(Constants.yourCard)
            .font(FontsUi.APC_Body_Bold)
            .foregroundColor(ColorsUi.APC_Black)
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 20, alignment: .leading)
        
        VStack{}.frame(height: 10)
        
        SingleStoredCardBanner(paymentMethod: paymentMethod)
    }
}
