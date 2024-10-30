//
//  MultipleStoredCards.swift
//
//
//  Created by Graciano Caldeira on 18/10/2024.
//

import SwiftUI
@_implementationOnly import Adyen

struct MultipleStoredCards: View {
    
    @ObservedObject var viewModel: BottomSheetViewModel
    @ObservedObject var adyenController: AdyenController
    @Binding var chosenStoredCard: StoredCardPaymentMethod?
    var storedPaymentMethods: [any StoredPaymentMethod]
    
    var body: some View {
        Text(Constants.chooseCard)
            .font(FontsUi.APC_Body_Bold)
            .foregroundColor(ColorsUi.APC_Black)
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 20, alignment: .leading)
        
        VStack {}.frame(height: 10)
        
        VStack(spacing: 0) {
            
            ForEach(0 ..< storedPaymentMethods.count, id: \.self) { paymentMethodNumber in
                
                if let paymentMethod = storedPaymentMethods[paymentMethodNumber] as? StoredCardPaymentMethod {
                    Button(action: { self.chosenStoredCard = paymentMethod }) {
                        ZStack {
                            ColorsUi.APC_White
                            HStack(spacing: 0) {
                                
                                if let image = adyenController.getCardLogo(for: paymentMethod) {
                                    CreditCardAdyenIcon(image: image)
                                        .padding(.trailing, 16)
                                        .padding(.leading, 16)
                                        .animation(.easeIn(duration: 0.3))
                                }
                                
                                Text(verbatim: "···· " + paymentMethod.lastFour)
                                    .foregroundColor(ColorsUi.APC_Black)
                                    .font(FontsUi.APC_Subheadline)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if paymentMethod.identifier == chosenStoredCard?.identifier {
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .edgesIgnoringSafeArea(.all)
                                        .foregroundColor(ColorsUi.APC_Pink)
                                        .frame(width: 22, height: 22, alignment: .trailing)
                                    
                                    VStack {}.frame(width: 16)
                                } else {
                                    Circle()
                                        .strokeBorder(ColorsUi.APC_LightGray, lineWidth: 2)
                                        .frame(width: 22, height: 22, alignment: .trailing)
                                    
                                    VStack {}.frame(width: 16)
                                }
                            }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                        }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                    }
                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                    .buttonStyle(flatButtonStyle())
                }
                
                if paymentMethodNumber < storedPaymentMethods.count - 1 {
                    Divider()
                        .background(ColorsUi.APC_Gray)
                }
            }
            
        }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48)
            .cornerRadius(13)
    }
}
