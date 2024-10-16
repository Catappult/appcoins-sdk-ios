//
//  LastPaymentMethodView.swift
//  
//
//  Created by Graciano Caldeira on 04/10/2024.
//

import SwiftUI

struct LastPaymentMethodView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var paypalViewModel: PayPalDirectViewModel = PayPalDirectViewModel.shared
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
                        
                            //                            VStack(spacing: 0) {
                            //                                VStack {}.frame(height: 10)
                            //
                            //                                HStack {
                            //                                    Image("gift-pink", bundle: Bundle.module)
                            //                                        .resizable()
                            //                                        .edgesIgnoringSafeArea(.all)
                            //                                        .frame(width: 16, height: 16)
                            //
                            //                                    if let bonusCurrency = transactionViewModel.transaction?.bonusCurrency.sign, let bonusAmount = transactionViewModel.transaction?.bonusAmount {
                            //                                        Text(String(format: Constants.purchaseBonus, "\(bonusCurrency)\(String(format: "%.3f", bonusAmount))"))
                            //                                            .font(FontsUi.APC_Caption1_Bold)
                            //                                            .foregroundColor(ColorsUi.APC_White)
                            //                                            .frame(height: 16)
                            //                                            .id("top")
                            //                                    } else {
                            //                                        HStack(spacing: 0) {
                            //                                            Text("")
                            //                                                .skeleton(with: true)
                            //                                                .font(FontsUi.APC_Caption1_Bold)
                            //                                                .opacity(0.1)
                            //                                                .frame(width: 40, height: 17)
                            //                                        }
                            //                                    }
                            //
                            //                                    Image("appc-payment-method-pink", bundle: Bundle.module)
                            //                                        .resizable()
                            //                                        .edgesIgnoringSafeArea(.all)
                            //                                        .frame(width: 16, height: 16)
                            //                                }
                            //
                            //                                VStack {}.frame(height: 4)
                            //
                            //                                Text(Constants.canSeeBonusText)
                            //                                    .font(FontsUi.APC_Caption2)
                            //                                    .foregroundColor(ColorsUi.APC_Gray)
                            //                                    .frame(height: 13)
                            //
                            //                                VStack {}.frame(height: 10)
                            //                            }
                            //                            .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 56)
                            //                            .background(ColorsUi.APC_DarkBlue)
                            //                            .cornerRadius(12)
                        PurchaseBonusBanner(viewModel: viewModel, transactionViewModel: transactionViewModel)
                        
                        VStack {}.frame(height: 16)
                        
                        // Last Payment method
                        HStack(spacing: 0) {
                            VStack(spacing: 0) {
                                
                                ZStack {
                                    ColorsUi.APC_White
                                    
                                    HStack(spacing: 0) {
                                        VStack(spacing: 0) {
                                            if let icon = URL(string: transactionViewModel.lastPaymentMethod?.icon ?? "") {
                                                PaymentMethodQuickIcon(icon: icon)
                                            }
                                        }
                                        
                                        VStack(spacing: 0) {
                                            if transactionViewModel.lastPaymentMethod?.name == Method.appc.rawValue {
                                                Text(transactionViewModel.lastPaymentMethod?.label)
                                                    .foregroundColor(ColorsUi.APC_Black)
                                                    .font(FontsUi.APC_Callout)
                                                    .lineLimit(1)
                                                    .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 168 : UIScreen.main.bounds.width - 48 - 168, alignment: .leading)
                                                    .padding(.bottom, 4)
                                                
                                                Text(Constants.earnedEnoughAppcText)
                                                    .foregroundColor(ColorsUi.APC_Gray)
                                                    .font(FontsUi.APC_Caption1)
                                                    .lineLimit(2)
                                                    .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 168 : UIScreen.main.bounds.width - 48 - 168, alignment: .leading)
                                                
                                            } else {
                                                Text(transactionViewModel.lastPaymentMethod?.label)
                                                    .foregroundColor(ColorsUi.APC_Black)
                                                    .font(FontsUi.APC_Callout)
                                                    .lineLimit(1)
                                                    .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 168 : UIScreen.main.bounds.width - 48 - 168, alignment: .leading)
                                            }
                                        }.frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 168 : UIScreen.main.bounds.width - 48 - 96, alignment: .leading)
                                            .padding(.leading, 16)
                                    }
                                }
                                .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 88)
                                .cornerRadius(13)
                                
                                HStack {}.frame(height: 16)
                                
                                HStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        if transactionViewModel.paypalLogOut {
                                            Button(action: paypalViewModel.logoutPayPal) {
                                                Text(Constants.logOut)
                                                    .foregroundColor(ColorsUi.APC_DarkGray)
                                                    .font(FontsUi.APC_Caption2_Bold)
                                            }
                                        }
                                    }.frame(width: 50, alignment: .leading)
                                    
                                    HStack(spacing: 0) {
                                        Button(action: transactionViewModel.showPaymentMethodOptions) {
                                            Text(Constants.otherPaymentMethodsText)
                                                .foregroundColor(ColorsUi.APC_Pink)
                                                .font(FontsUi.APC_Subheadline)
                                                .lineLimit(1)
                                                .padding(.trailing, 8)
                                                .onAppear(perform: {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                                        withAnimation(.easeInOut(duration: 30)) {
                                                            scrollViewProxy.scrollTo("top", anchor: .top)
                                                        }
                                                    }
                                                })
                                        }
                                    }.frame(maxWidth: .infinity, alignment: .trailing)
                                }.frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 18)
                            }
                        }
                        
                        HStack {}.frame(height: !transactionViewModel.showOtherPaymentMethods ? 40 : 26)
                        
                    }.ignoresSafeArea(.all)
                }.defaultScrollAnchor(.bottom)
            }
        }
    }
}
