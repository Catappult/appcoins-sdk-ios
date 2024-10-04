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
            HStack(spacing: 0) {
                
                VStack {}.frame(width: 24)
                
                Image(uiImage: Utils.getAppIcon())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .frame(maxWidth: 40, alignment: .leading)
                
                VStack {}.frame(width: 15)
                
                VStack(alignment: .leading, spacing: 0) {
                    if let title = transactionViewModel.transaction?.getTitle() {
                        Text(title)
                            .foregroundColor(ColorsUi.APC_Black)
                            .font(FontsUi.APC_Body_Bold)
                            .lineLimit(1)
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
                            
                            VStack {}.frame(width: 4)
                            
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
                        
                        VStack {}.frame(width: 16)
                        
                        if let appcAmount = transactionViewModel.transaction?.appcAmount {
                            Text(verbatim: String(format: "%.3f", appcAmount) + " APPC")
                                .foregroundColor(ColorsUi.APC_Gray)
                                .font(FontsUi.APC_Caption2)
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
                    .frame(width: UIScreen.main.bounds.width - 154, alignment: .bottomLeading)
                    
                    VStack {}.frame(height: 4)
                    
                }.frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                
                Button {
                    viewModel.dismiss()
                } label: {
                    ZStack {
                        Circle()
                            .fill(ColorsUi.APC_BackgroundLightGray_Button)
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "xmark")
                            .foregroundColor(ColorsUi.APC_DarkGray_Xmark)
                    }
                }
                
                VStack {}.frame(width: 24)
                
            }
            .frame(width: UIScreen.main.bounds.width, height: 72)
            
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
            .frame(width: UIScreen.main.bounds.width - 48, height: 56)
            .background(ColorsUi.APC_DarkBlue)
            .cornerRadius(12)
            
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
