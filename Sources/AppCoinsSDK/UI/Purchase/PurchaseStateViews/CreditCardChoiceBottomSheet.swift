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
    
    // Calculation of the available space needed for the stored cards
    let headerHeight: CGFloat = 72
    let headerBottomPadding: CGFloat = 8
    let purchaseBonusBannerHeight: CGFloat = 56
    let purchaseBonusBannerBottomPadding: CGFloat = 16
    let textHeight: CGFloat = 20
    let textBottomPadding: CGFloat = 10
    let storedCardListBottomPadding: CGFloat = 8
    let addCardButtonHeight: CGFloat = 18
    let addCardButtonBottomPadding: CGFloat = 10
    let buyButtonHeight: CGFloat = 50
    let buyButtonTopPadding: CGFloat = 8
    let cardHeight: CGFloat = 50
    let buyButtonBottomPadding: CGFloat
    let bottomSheetHeight: CGFloat
    let spaceAvailable: CGFloat
    let numberOfCards: Int
    
    internal init(viewModel: BottomSheetViewModel) {
        self.viewModel = viewModel
        
        if let firstStoredCard = AdyenController.shared.session?.sessionContext.paymentMethods.stored.first as? StoredCardPaymentMethod {
            // Only way to initialize a State variable on init method: https://stackoverflow.com/a/58137096/18917552
            _chosenStoredCard = State(initialValue: firstStoredCard)
        }
        
        if Utils.bottomSafeAreaHeight == 0 {
            self.buyButtonBottomPadding = 5
        } else {
            self.buyButtonBottomPadding = 28
        }
        
        if viewModel.orientation == .landscape {
            self.bottomSheetHeight = UIScreen.main.bounds.height * 0.9
        } else {
            self.bottomSheetHeight = 420
        }
        
        self.spaceAvailable = bottomSheetHeight - (headerHeight + headerBottomPadding + purchaseBonusBannerHeight + purchaseBonusBannerBottomPadding + textHeight + textBottomPadding + storedCardListBottomPadding + addCardButtonHeight + addCardButtonBottomPadding + buyButtonHeight + buyButtonTopPadding + buyButtonBottomPadding)
        
        self.numberOfCards = Int(spaceAvailable / cardHeight)
        
    }
    
    internal var body: some View {
        
        if let storedPaymentMethods = adyenController.session?.sessionContext.paymentMethods.stored {
            if storedPaymentMethods.count > numberOfCards || storedPaymentMethods.count >= numberOfCards && spaceAvailable < cardHeight {
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
                                            
                                            if storedPaymentMethods.count == 1 {
                                                if let paymentMethod = storedPaymentMethods.first as? StoredCardPaymentMethod {
                                                    OneStoredCard(viewModel: viewModel, adyenController: adyenController, paymentMethod: paymentMethod)
                                                }
                                            } else {
                                                MultipleStoredCards(viewModel: viewModel, adyenController: adyenController, chosenStoredCard: $chosenStoredCard, storedPaymentMethods: storedPaymentMethods)
                                            }
                                            
                                            VStack {}.frame(height: 8)
                                            
                                            Button(action: adyenViewModel.payWithNewCreditCard) {
                                                Text(Constants.addCard)
                                                    .foregroundColor(ColorsUi.APC_Pink)
                                                    .font(FontsUi.APC_Footnote_Bold)
                                                    .lineLimit(1)
                                                
                                            }
                                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 18, alignment: .trailing)
                                            .onAppear(perform: {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                                    withAnimation(.easeInOut(duration: 30)) {
                                                        scrollViewProxy.scrollTo("top", anchor: .top)
                                                    }
                                                }
                                            })
                                            
                                            VStack {}.frame(height: 10)
                                            
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
                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                            .foregroundColor(ColorsUi.APC_White)
                            
                            VStack {}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
                            
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
                        if let paymentMethod = storedPaymentMethods.first as? StoredCardPaymentMethod {
                            OneStoredCard(viewModel: viewModel, adyenController: adyenController, paymentMethod: paymentMethod)
                        }
                    } else {
                        VStack(spacing: 0) {
                            
                            MultipleStoredCards(viewModel: viewModel, adyenController: adyenController, chosenStoredCard: $chosenStoredCard, storedPaymentMethods: storedPaymentMethods)
                            
                            VStack {}.frame(height: 8)
                            
                        }
                    }
                    
                    Button(action: adyenViewModel.payWithNewCreditCard) {
                        Text(Constants.addCard)
                            .foregroundColor(ColorsUi.APC_Pink)
                            .font(FontsUi.APC_Footnote_Bold)
                            .lineLimit(1)
                        
                    }
                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 18, alignment: .trailing)
                    
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
                    
                    VStack {}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
                }
            }
        }
    }
}
