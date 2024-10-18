//
//  OneStoredCard.swift
//
//
//  Created by Graciano Caldeira on 18/10/2024.
//

import SwiftUI
import Adyen

struct OneStoredCard: View {
    
    @ObservedObject var viewModel: BottomSheetViewModel
    @ObservedObject var adyenController: AdyenController
    var paymentMethod: StoredCardPaymentMethod
    
    var body: some View {
        VStack(spacing: 0) {
            Text(Constants.yourCard)
                .font(FontsUi.APC_Body_Bold)
                .foregroundColor(ColorsUi.APC_Black)
                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 20, alignment: .leading)
            
            VStack {}.frame(height: 10)
            
            HStack(spacing: 0) {
                
                VStack {}.frame(width: 16)
                
                if let image = adyenController.getCardLogo(for: paymentMethod) {
                    CreditCardAdyenIcon(image: image)
                        .animation(.easeIn(duration: 0.3))
                }
                
                VStack {}.frame(width: 16)
                
                Text(verbatim: "···· " + paymentMethod.lastFour)
                    .foregroundColor(ColorsUi.APC_Black)
                    .font(FontsUi.APC_Subheadline)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
            .background(ColorsUi.APC_White)
            .cornerRadius(10)
            
            VStack {}.frame(height: 8)
            
        }.frame(alignment: .top)
    }
}
