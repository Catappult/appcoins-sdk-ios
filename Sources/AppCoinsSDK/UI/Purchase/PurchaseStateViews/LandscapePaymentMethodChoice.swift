//
//  PaymentMethodChoiceView.swift
//
//
//  Created by Graciano Caldeira on 04/10/2024.
//

import SwiftUI

struct PaymentMethodChoiceView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    var body: some View {
        if #available(iOS 17, *) {
            ScrollViewReader { scrollViewProxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        VStack {}.frame(height: 72)
                            .id("top")
                            .onAppear(perform: {
                                scrollViewProxy.scrollTo("bottom", anchor: .bottom)
                            })
                        
                        VStack {}.frame(height: 8)
                        
                        VStack(spacing: 0) {
                            if transactionViewModel.paymentMethodSelected != nil && transactionViewModel.paymentMethodSelected?.name != Method.appc.rawValue {
                                
                                VStack {}.frame(height: 10)
                                
                                HStack {
                                    Image("gift-pink", bundle: Bundle.module)
                                        .resizable()
                                        .edgesIgnoringSafeArea(.all)
                                        .frame(width: 16, height: 16)
                                    
                                    if let bonusCurrency = transactionViewModel.transaction?.bonusCurrency.sign, let bonusAmount = transactionViewModel.transaction?.bonusAmount {
                                        Text(String(format: Constants.purchaseBonus, "\(bonusCurrency)\(String(format: "%.3f", bonusAmount))"))
                                            .font(FontsUi.APC_Caption1_Bold)
                                            .foregroundColor(ColorsUi.APC_White)
                                            .frame(height: 16)
                                            .id("top")
                                    } else {
                                        HStack(spacing: 0) {
                                            Text("")
                                                .skeleton(with: true)
                                                .font(FontsUi.APC_Caption1_Bold)
                                                .opacity(0.1)
                                                .frame(width: 40, height: 17)
                                        }
                                    }
                                    
                                    Image("appc-payment-method-pink", bundle: Bundle.module)
                                        .resizable()
                                        .edgesIgnoringSafeArea(.all)
                                        .frame(width: 16, height: 16)
                                }
                                
                                VStack {}.frame(height: 4)
                                
                                Text(Constants.canSeeBonusText)
                                    .font(FontsUi.APC_Caption2)
                                    .foregroundColor(ColorsUi.APC_Gray)
                                    .frame(height: 13)
                                
                                VStack {}.frame(height: 10)
                            }
                        }
                        .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 56)
                        .background(ColorsUi.APC_DarkBlue)
                        .cornerRadius(12)
                        
                        
                        VStack {}.frame(height: 16)
                        
                        // Payment methods
                        HStack(spacing: 0) {
                            VStack(spacing: 0) {
                                RadioButtonGroupView(viewModel: viewModel)
                                    .onAppear(perform: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                            withAnimation(.easeInOut(duration: 30)) {
                                                scrollViewProxy.scrollTo("top", anchor: .top)
                                            }
                                        }
                                    })
                            }
                        }
                        
                        HStack {}.frame(height: !transactionViewModel.showOtherPaymentMethods ? 40 : 26)
                        
                    }.ignoresSafeArea(.all)
                }.defaultScrollAnchor(.bottom)
            }
        }
    }
}
