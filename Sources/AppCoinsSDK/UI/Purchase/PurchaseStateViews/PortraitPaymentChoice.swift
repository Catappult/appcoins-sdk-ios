//
//  PortraitPaymentChoice.swift
//
//
//  Created by Graciano Caldeira on 04/10/2024.
//

import SwiftUI

struct PortraitPaymentChoice: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var paypalViewModel: PayPalDirectViewModel = PayPalDirectViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    var body: some View {
        VStack(spacing: 0) {
            
            BottomSheetAppHeader(viewModel: viewModel, transactionViewModel: transactionViewModel)
            
            VStack {}.frame(height: 8)
            
            PurchaseBonusBanner(viewModel: viewModel, transactionViewModel: transactionViewModel)
            
            VStack {}.frame(height: 16)
            
            if transactionViewModel.lastPaymentMethod != nil || transactionViewModel.showOtherPaymentMethods {
                
                // Payment methods
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        if (!transactionViewModel.showOtherPaymentMethods) {
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
                                                .frame(width: UIScreen.main.bounds.width - 168, alignment: .leading)
                                                .padding(.bottom, 4)
                                            
                                            Text(Constants.earnedEnoughAppcText)
                                                .foregroundColor(ColorsUi.APC_Gray)
                                                .font(FontsUi.APC_Caption1)
                                                .lineLimit(2)
                                                .frame(width: UIScreen.main.bounds.width - 168, alignment: .leading)
                                        } else {
                                            Text(transactionViewModel.lastPaymentMethod?.label)
                                                .foregroundColor(ColorsUi.APC_Black)
                                                .font(FontsUi.APC_Callout)
                                                .lineLimit(1)
                                                .frame(width: UIScreen.main.bounds.width - 168, alignment: .leading)
                                        }
                                    }.frame(width: UIScreen.main.bounds.width - 168, alignment: .leading)
                                        .padding(.leading, 16)
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width - 48, height: 88)
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
                                    }
                                }.frame(maxWidth: .infinity, alignment: .trailing)
                            }.frame(width: UIScreen.main.bounds.width - 48, height: 18)
                        } else {
                            RadioButtonGroupView(viewModel: viewModel)
                        }
                    }
                }
                
                HStack {}.frame(height: !transactionViewModel.showOtherPaymentMethods ? 40 : 26)
                
            } else {
                VStack(spacing: 0) {
                    VStack {}
                        .skeleton(with: true, shape: .rectangle)
                        .cornerRadius(13)
                        .frame(width: UIScreen.main.bounds.width - 48, height: 150)
                }
            }
            
            // Buying button
            Button(action: {
                DispatchQueue.main.async { viewModel.purchaseState = .processing }
                viewModel.buy()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(transactionViewModel.transaction != nil ? ColorsUi.APC_Pink : ColorsUi.APC_Gray)
                    Text(Constants.buyText)
                }
            }
            .disabled(transactionViewModel.transaction == nil)
            .frame(width: UIScreen.main.bounds.width - 48, height: 50)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .foregroundColor(ColorsUi.APC_White)
            
            VStack {}.frame(height: 21)
            
        }.ignoresSafeArea(.all)
    }
}
