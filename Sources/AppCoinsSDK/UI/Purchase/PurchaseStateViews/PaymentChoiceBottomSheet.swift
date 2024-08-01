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
            HStack(spacing: 0) {}.frame(height: 23)
            
            // Avatar and purchase
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Image(uiImage: Utils.getAppIcon())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 74, height: 74)
                        .clipShape(Circle())
                }
                
                VStack(spacing: 0){}.frame(width: 16)
                
                VStack(spacing: 0) {
                    if let title = transactionViewModel.transaction?.getTitle() {
                        Text(title)
                            .foregroundColor(APPCColor.black)
                            .font(FontsUi.APC_Body_Bold)
                            .lineLimit(2)
                            .frame(width: UIScreen.main.bounds.width - 154, alignment: .leading)
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
                            Text((Coin(rawValue: transactionViewModel.transaction?.moneyCurrency ?? "")?.symbol ?? "") + String(amount))
                                .foregroundColor(APPCColor.black)
                                .font(FontsUi.APC_Subheadline_Bold)
                                .lineLimit(1)
                                .padding(.trailing, 3)
                            Text(transactionViewModel.transaction?.moneyCurrency ?? "-")
                                .foregroundColor(APPCColor.black)
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
                    }.frame(width: UIScreen.main.bounds.width - 154, alignment: .bottomLeading)
                        .padding(.top, 11)
                    
                    if let appcAmount = transactionViewModel.transaction?.appcAmount {
                        Text(verbatim: String(format: "%.3f", appcAmount) + " APPC")
                            .foregroundColor(APPCColor.gray)
                            .font(FontsUi.APC_Caption2)
                            .frame(width: UIScreen.main.bounds.width - 154, alignment: .leading)
                    } else {
                        HStack(spacing: 0) {
                            Text("")
                                .skeleton(with: true)
                                .frame(width: 55, height: 10, alignment: .leading)
                                .padding(.top, 2)
                            VStack {}.frame(maxWidth: .infinity)
                        }.frame(maxWidth: .infinity)
                    }
                }.frame(width: UIScreen.main.bounds.width - 154, alignment: .topLeading)
                
            }.frame(width: UIScreen.main.bounds.width - 64, height: 74, alignment: .top)

            HStack(spacing: 0) {}.frame(height: 23)
            
            if transactionViewModel.lastPaymentMethod != nil || transactionViewModel.showOtherPaymentMethods {
                // Payment methods
                HStack(spacing: 0) {
                    
                    VStack(spacing: 0) {
                        
                        if (!transactionViewModel.showOtherPaymentMethods) {
                            ZStack {
                                APPCColor.white
                                
                                HStack(spacing: 0) {
                                    VStack(spacing: 0) {
                                        if let icon = URL(string: transactionViewModel.lastPaymentMethod?.icon ?? "") {
                                            PaymentMethodQuickIcon(icon: icon)
                                        }
                                    }
                                    
                                    VStack(spacing: 0) {
                                        if transactionViewModel.lastPaymentMethod?.name == Method.appc.rawValue {
                                            Text(transactionViewModel.lastPaymentMethod?.label)
                                                .foregroundColor(APPCColor.black)
                                                .font(FontsUi.APC_Callout)
                                                .lineLimit(1)
                                                .frame(width: UIScreen.main.bounds.width - 168, alignment: .leading)
                                                .padding(.bottom, 4)
                                            
                                            Text(Constants.earnedEnoughAppcText)
                                                .foregroundColor(APPCColor.gray)
                                                .font(FontsUi.APC_Caption1)
                                                .lineLimit(2)
                                                .frame(width: UIScreen.main.bounds.width - 168, alignment: .leading)
                                        } else {
                                            Text(transactionViewModel.lastPaymentMethod?.label)
                                                .foregroundColor(APPCColor.black)
                                                .font(FontsUi.APC_Callout)
                                                .lineLimit(1)
                                                .frame(width: UIScreen.main.bounds.width - 168, alignment: .leading)
                                        }
                                    }.frame(width: UIScreen.main.bounds.width - 168, alignment: .leading)
                                        .padding(.leading, 16)
                                }
                            }.frame(width: UIScreen.main.bounds.width - 64, height: 88)
                                .cornerRadius(13)
                            
                            HStack(spacing: 0){}.frame(height: 9)
                            
                            HStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    if transactionViewModel.paypalLogOut {
                                        Button(action: paypalViewModel.logoutPayPal) {
                                            Text(Constants.logOut)
                                                .foregroundColor(APPCColor.darkGray)
                                                .font(FontsUi.APC_Caption2_Bold)
                                        }
                                    }
                                }.frame(width: 50, alignment: .leading)
                                
                                HStack(spacing: 0) {
                                    Button(action: transactionViewModel.showPaymentMethodOptions) {
                                        Text(Constants.otherPaymentMethodsText)
                                            .foregroundColor(APPCColor.pink)
                                            .font(FontsUi.APC_Footnote_Bold)
                                            .lineLimit(1)
                                            .padding(.trailing, 8)
                                    }
                                    Button(action: transactionViewModel.showPaymentMethodOptions) {
                                        Image(systemName: "chevron.forward")
                                            .resizable()
                                            .edgesIgnoringSafeArea(.all)
                                            .foregroundColor(APPCColor.pink)
                                            .frame(width: 4, height: 8)
                                    }
                                }.frame(maxWidth: .infinity, alignment: .trailing)
                            }.frame(width: UIScreen.main.bounds.width - 64, height: 18)
                        } else {
                            RadioButtonGroupView(viewModel: viewModel)
                        }
                    }
                }
            }
            
            HStack(spacing: 0){}.frame(height: 20)
            
            // Buying button
            Button(action: {
                DispatchQueue.main.async { viewModel.purchaseState = .processing }
                viewModel.buy()
            }) {
                ZStack {
                    if transactionViewModel.transaction != nil {
                        APPCColor.pink
                    } else {
                        APPCColor.gray
                    }
                    Text(Constants.buyText)
                }
            }
            .disabled(transactionViewModel.transaction == nil)
            .frame(width: UIScreen.main.bounds.width - 64, height: 48)
            .foregroundColor(APPCColor.white)
            .cornerRadius(10)
            
            HStack(spacing: 0){}.frame(height: 14)
            
            Button(action: {
                viewModel.dismiss()
            }) {
                Text(Constants.cancelText)
                    .foregroundColor(APPCColor.darkGray)
                    .font(FontsUi.APC_Footnote_Bold)
                    .lineLimit(1)
            }
            .frame(height: 18)
            
            HStack(spacing: 0){}.frame(height: 20)
            
        }
    
    }
}

