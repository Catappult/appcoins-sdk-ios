//
//  CreditCardChoiceBottomSheet.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import SwiftUI
import Adyen
import AdyenCard
import URLImage

internal struct CreditCardChoiceBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    @ObservedObject internal var adyenViewModel: AdyenViewModel = AdyenViewModel.shared
    
    @State internal var chosenStoredCard: StoredCardPaymentMethod?
    
    internal init(viewModel: BottomSheetViewModel) {
        self.viewModel = viewModel
        
        if let firstStoredCard = AdyenController.shared.session?.sessionContext.paymentMethods.stored.first as? StoredCardPaymentMethod {
            // Only way to initialize a State variable on init method: https://stackoverflow.com/a/58137096/18917552
            _chosenStoredCard = State(initialValue: firstStoredCard)
        }
    }
    
    internal var body: some View {
        
        VStack(spacing: 0) {
            
            if let storedPaymentMethods = adyenController.session?.sessionContext.paymentMethods.stored {
                
                Text(Constants.chooseCard)
                    .font(FontsUi.APC_Body_Bold)
                    .foregroundColor(ColorsUi.APC_Black)
                    .frame(width: UIScreen.main.bounds.width - 64, height: 22, alignment: .leading)
                    .padding(.top, 24)
                    .padding(.bottom, 18)
                
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
                                                .padding(.trailing, 16)
                                        } else {
                                            Circle()
                                                .strokeBorder(ColorsUi.APC_LightGray, lineWidth: 2)
                                                .frame(width: 22, height: 22, alignment: .trailing)
                                                .padding(.trailing, 16)
                                        }
                                    }.frame(width: UIScreen.main.bounds.width - 64, height: 44)
                                }
                            }.buttonStyle(flatButtonStyle())
                    
                        }
                    
                        if paymentMethodNumber < storedPaymentMethods.count - 1 {
                            Divider()
                                .background(ColorsUi.APC_Gray)
                        }
                    }
                }.frame(width: UIScreen.main.bounds.width - 64)
                .cornerRadius(13)
            }
            
            HStack(spacing: 0) {
                Button(action: adyenViewModel.payWithNewCreditCard) {
                    Text(Constants.addCard)
                        .foregroundColor(ColorsUi.APC_Pink)
                        .font(FontsUi.APC_Footnote_Bold)
                        .lineLimit(1)
                        .padding(.trailing, 8)
                }
                Button(action: adyenViewModel.payWithNewCreditCard) {
                    Image(systemName: "chevron.forward")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .foregroundColor(ColorsUi.APC_Pink)
                        .frame(width: 4, height: 8)
                }
            }.frame(width: UIScreen.main.bounds.width - 64, height: 18, alignment: .trailing)
                .padding(.top, 9)
                .padding(.bottom, 18)
            
            Button(action: { if let storedPaymentMethod = self.chosenStoredCard { adyenViewModel.payWithStoredCreditCard(creditCard: storedPaymentMethod) }}) {
                ZStack {
                    ColorsUi.APC_Pink
                    
                    Text(Constants.buyText)
                        .foregroundColor(ColorsUi.APC_White)
                        .font(FontsUi.APC_Body_Bold)
                }
            }
            .frame(width: UIScreen.main.bounds.width - 64, height: 48)
            .foregroundColor(ColorsUi.APC_White)
            .cornerRadius(10)
            
            Button(action: {
                adyenController.cancel()
            }) {
                Text(Constants.cancelText)
                    .foregroundColor(ColorsUi.APC_DarkGray)
                    .font(FontsUi.APC_Footnote_Bold)
                    .lineLimit(1)
            }
            .frame(height: 18)
            .padding(.top, 14)
            .padding(.bottom, 30)
            
        }
    }
}
