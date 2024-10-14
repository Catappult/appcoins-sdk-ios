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
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    @State internal var chosenStoredCard: StoredCardPaymentMethod?
    
    internal init(viewModel: BottomSheetViewModel) {
        self.viewModel = viewModel
        
        if let firstStoredCard = AdyenController.shared.session?.sessionContext.paymentMethods.stored.first as? StoredCardPaymentMethod {
            // Only way to initialize a State variable on init method: https://stackoverflow.com/a/58137096/18917552
            _chosenStoredCard = State(initialValue: firstStoredCard)
        }
    }
    
    internal var body: some View {
        
        if let storedPaymentMethods = adyenController.session?.sessionContext.paymentMethods.stored {
            if storedPaymentMethods.count > 2 {
                if #available(iOS 17, *) {
                    ZStack(alignment: .top) {
                        VStack(spacing: 0) {
                            ScrollViewReader { scrollViewProxy in
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(spacing: 0) {
                                        VStack {}.frame(height: 72)
                                            .id("top")
                                        
                                        VStack {}.frame(height: 8)
                                        
                                        VStack(spacing: 0) {
                                            
                                            PurchaseBonusBanner(viewModel: viewModel, transactionViewModel: transactionViewModel)
                                            
                                            VStack {}.frame(height: 16)
                                            
                                            Text(Constants.chooseCard)
                                                .font(FontsUi.APC_Body_Bold)
                                                .foregroundColor(ColorsUi.APC_Black)
                                                .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 20, alignment: .leading)
                                            
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
                                                                }.frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                                                            }.frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                                                        }
                                                        .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                                                        .buttonStyle(flatButtonStyle())
                                                        
                                                    }
                                                    
                                                    if paymentMethodNumber < storedPaymentMethods.count - 1 {
                                                        Divider()
                                                            .background(ColorsUi.APC_Gray)
                                                    }
                                                }
                                            }.frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48)
                                                .cornerRadius(13)
                                            
                                            VStack {}.frame(height: 9)
                                            
                                            Button(action: adyenViewModel.payWithNewCreditCard) {
                                                Text(Constants.addCard)
                                                    .foregroundColor(ColorsUi.APC_Pink)
                                                    .font(FontsUi.APC_Footnote_Bold)
                                                    .lineLimit(1)
                                                
                                            }
                                            .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 18, alignment: .trailing)
                                            .onAppear(perform: {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                                    withAnimation(.easeInOut(duration: 30)) {
                                                        scrollViewProxy.scrollTo("top", anchor: .top)
                                                    }
                                                }
                                            })
                                        }
                                    }.ignoresSafeArea(.all)
                                }.defaultScrollAnchor(.bottom)
                            }
                            
                            VStack {}.frame(height: 8)
                            
                            Button(action: { if let storedPaymentMethod = self.chosenStoredCard { adyenViewModel.payWithStoredCreditCard(creditCard: storedPaymentMethod) }}) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(transactionViewModel.transaction != nil ? ColorsUi.APC_Pink : ColorsUi.APC_Gray)
                                    Text(Constants.buyText)
                                }
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                            .foregroundColor(ColorsUi.APC_White)
                            
                            VStack {}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 21)
                            
                        }.frame(maxHeight: .infinity, alignment: .bottom)
                        
                        BottomSheetAppHeader(viewModel: viewModel, transactionViewModel: transactionViewModel)
                            
                    }
                }
            } else {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        BottomSheetAppHeader(viewModel: viewModel, transactionViewModel: transactionViewModel)
                        
                        VStack {}.frame(height: 8)
                        
                        PurchaseBonusBanner(viewModel: viewModel, transactionViewModel: transactionViewModel)
                        
                        VStack {}.frame(height: 16)
                    }.frame(alignment: .top)
                    
                        if storedPaymentMethods.count == 1 {
                            VStack(spacing: 0) {
                                Text(Constants.yourCard)
                                    .font(FontsUi.APC_Body_Bold)
                                    .foregroundColor(ColorsUi.APC_Black)
                                    .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 20, alignment: .leading)
                                
                                VStack {}.frame(height: 10)
                                
                                HStack(spacing: 0) {
                                    if let paymentMethod = storedPaymentMethods.first as? StoredCardPaymentMethod {
                                        
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
                                }
                                .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                                .background(ColorsUi.APC_White)
                                .cornerRadius(10)
                                
                                VStack {}.frame(height: 8)
                                
                                HStack(spacing: 0) {
                                    
                                    Button(action: adyenViewModel.payWithNewCreditCard) {
                                        Text(Constants.addCard)
                                            .foregroundColor(ColorsUi.APC_Pink)
                                            .font(FontsUi.APC_Footnote_Bold)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 18, alignment: .trailing)
                            }.frame(alignment: .top)
                            
                        } else {
                            VStack(spacing: 0) {
                                Text(Constants.chooseCard)
                                    .font(FontsUi.APC_Body_Bold)
                                    .foregroundColor(ColorsUi.APC_Black)
                                    .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 20, alignment: .leading)
                                
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
                                                    }.frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                                                }.frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                                            }
                                            .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                                            .buttonStyle(flatButtonStyle())
                                            
                                        }
                                        
                                        if paymentMethodNumber < storedPaymentMethods.count - 1 {
                                            Divider()
                                                .background(ColorsUi.APC_Gray)
                                        }
                                    }
                                }.frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48)
                                    .cornerRadius(13)
                                
                                VStack {}.frame(height: 9)
                                
                                Button(action: adyenViewModel.payWithNewCreditCard) {
                                    Text(Constants.addCard)
                                        .foregroundColor(ColorsUi.APC_Pink)
                                        .font(FontsUi.APC_Footnote_Bold)
                                        .lineLimit(1)
                                    
                                }.frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 18, alignment: .trailing)
                                
                                VStack {}.frame(height: 18)
                            }
                        }
                    
                    
                    Button(action: { if let storedPaymentMethod = self.chosenStoredCard { adyenViewModel.payWithStoredCreditCard(creditCard: storedPaymentMethod) }}) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(transactionViewModel.transaction != nil ? ColorsUi.APC_Pink : ColorsUi.APC_Gray)
                            Text(Constants.buyText)
                        }
                    }
                    .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .foregroundColor(ColorsUi.APC_White)
                    
                    VStack {}.frame(height: 21)
                }
            }
        }
    }
}
