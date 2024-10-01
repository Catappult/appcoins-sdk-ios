//
//  PaymentChoiceBottomSheet.swift
//
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI
import URLImage
import SkeletonUI

internal struct PaymentChoiceBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var paypalViewModel: PayPalDirectViewModel = PayPalDirectViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    internal var body: some View {
        
        VStack(spacing: 0) {
            
            VStack {}.frame(height: 15)
            
            // Avatar and purchase
            HStack(spacing: 0) {
                Image(uiImage: Utils.getAppIcon())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 74, height: 74)
                    .clipShape(Circle())
                
                VStack {}.frame(width: 15, height: 15)
                
                VStack(spacing: 0) {
                    if let title = transactionViewModel.transaction?.getTitle() {
                        Text(title)
                            .foregroundColor(ColorsUi.APC_Black)
                            .font(FontsUi.APC_Body_Bold)
                            .lineLimit(2)
                            .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 154 : UIScreen.main.bounds.width - 154, alignment: .leading)
                    } else {
                        HStack(spacing: 0) {
                            Text("")
                                .skeleton(with: true)
                                .frame(width: 125, height: 22, alignment: .leading)
                            VStack {}.frame(maxWidth: .infinity)
                        }.frame(maxWidth: .infinity)
                    }
                    
                    HStack(spacing: 0) {
                        if let amount = transactionViewModel.transaction?.moneyAmount {
                            Text((transactionViewModel.transaction?.moneyCurrency.sign ?? "") + String(amount))
                                .foregroundColor(ColorsUi.APC_Black)
                                .font(FontsUi.APC_Subheadline_Bold)
                                .lineLimit(1)
                                .padding(.trailing, 3)
                            Text(transactionViewModel.transaction?.moneyCurrency.currency ?? "-")
                                .foregroundColor(ColorsUi.APC_Black)
                                .font(FontsUi.APC_Caption1_Bold)
                                .lineLimit(1)
                        } else {
                            HStack(spacing: 0) {
                                Text("")
                                    .skeleton(with: true)
                                    .frame(width: 60, height: 14, alignment: .leading)
                                VStack {}.frame(maxWidth: .infinity)
                            }.frame(maxWidth: .infinity)
                        }
                    }
                    .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 154 : UIScreen.main.bounds.width - 154, alignment: .bottomLeading)
                    
                    VStack {}.frame(height: 4)
                    
                    if let appcAmount = transactionViewModel.transaction?.appcAmount {
                        Text(verbatim: String(format: "%.3f", appcAmount) + " APPC")
                            .foregroundColor(ColorsUi.APC_Gray)
                            .font(FontsUi.APC_Caption2)
                            .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 154 : UIScreen.main.bounds.width - 154, alignment: .leading)
                    } else {
                        HStack(spacing: 0) {
                            Text("")
                                .skeleton(with: true)
                                .frame(width: 55, height: 10, alignment: .leading)
                                .padding(.top, 2)
                            VStack {}.frame(maxWidth: .infinity)
                        }.frame(maxWidth: .infinity)
                    }
                }
                
                Button {
                    viewModel.dismiss()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5)))
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "xmark")
                            .foregroundColor(Color(UIColor(red: 0.24, green: 0.24, blue: 0.24, alpha: 1)))
                        
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                
            }.frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 32, height: 74, alignment: .top)
            
            HStack {}.frame(height: 15)
            
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
                                                .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 168 : UIScreen.main.bounds.width - 168, alignment: .leading)
                                                .padding(.bottom, 4)
                                            
                                            Text(Constants.earnedEnoughAppcText)
                                                .foregroundColor(ColorsUi.APC_Gray)
                                                .font(FontsUi.APC_Caption1)
                                                .lineLimit(2)
                                                .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 168 : UIScreen.main.bounds.width - 168, alignment: .leading)
                                        } else {
                                            Text(transactionViewModel.lastPaymentMethod?.label)
                                                .foregroundColor(ColorsUi.APC_Black)
                                                .font(FontsUi.APC_Callout)
                                                .lineLimit(1)
                                                .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 168 : UIScreen.main.bounds.width - 168, alignment: .leading)
                                        }
                                    }.frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 168 : UIScreen.main.bounds.width - 168, alignment: .leading)
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
                                    }
                                }.frame(maxWidth: .infinity, alignment: .trailing)
                            }.frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 18)
                        } else {
                            RadioButtonGroupView(viewModel: viewModel)
                        }
                    }
                }
            }
            
            HStack {}.frame(height: !transactionViewModel.showOtherPaymentMethods ? 42 : 26)
            
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
            .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 320 : UIScreen.main.bounds.width - 48, height: 50)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .foregroundColor(ColorsUi.APC_White)
            
            VStack {}.frame(height: 47)
        }
        .ignoresSafeArea(.all)
    }
}

