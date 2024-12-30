//
//  File.swift
//  
//
//  Created by aptoide on 30/12/2024.
//

import SwiftUI
@_implementationOnly import Adyen

internal struct StoredCardsListElement: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    
    internal var paymentMethod: StoredCardPaymentMethod
    @Binding internal var chosenStoredCard: StoredCardPaymentMethod?
    
    internal var icon: some View {
        VStack(spacing: 0) {
            if let image = adyenController.getCardLogo(for: paymentMethod) {
                CreditCardAdyenIcon(image: image)
                    .animation(.easeIn(duration: 0.3))
            }
        }.frame(width: 25)
    }
    
    internal var label: some View {
        Text(verbatim: "···· " + paymentMethod.lastFour)
            .foregroundColor(ColorsUi.APC_Black)
            .font(FontsUi.APC_Subheadline)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    internal var selector: some View {
        VStack(spacing: 0) {
            if paymentMethod.identifier == chosenStoredCard?.identifier {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .foregroundColor(ColorsUi.APC_Pink)
                    .frame(width: 22, height: 22, alignment: .trailing)
            } else {
                Circle()
                    .strokeBorder(ColorsUi.APC_LightGray, lineWidth: 2)
                    .frame(width: 22, height: 22, alignment: .trailing)
            }
        }.frame(width: 22)
    }
    
    internal var body: some View {
        Button(action: { self.chosenStoredCard = paymentMethod }) {
            ZStack {
                ColorsUi.APC_White
                
                HStack(spacing: 0) {
                    VStack{}.frame(width: 16)
                    
                    icon
                    
                    VStack{}.frame(width: 16)
                    
                    label
                    
                    selector
                    
                    VStack{}.frame(width: 16)
                }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
            }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
        .buttonStyle(flatButtonStyle())
    }
}



