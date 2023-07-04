//
//  PurchaseBottomSheet.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI
import URLImage
import SkeletonUI

struct PurchaseBottomSheet: View {
    
    @ObservedObject var viewModel: BottomSheetViewModel
    
    var baseHeight : CGFloat = 282
    
    var paymentMethodListHeight : CGFloat { return CGFloat(44*(viewModel.transaction?.paymentMethods.count ?? 0)) }
    var quickPaymentHeight : CGFloat = 110
    
    var blueStripeHeight : CGFloat {
        if viewModel.paymentMethodSelected != nil && viewModel.paymentMethodSelected?.name != "appcoins_credits" {
            // If bonus is shown
            return 166
        } else {
            // If bonus is not shown
            return 112
        }
    }
    
    @State private var transitionEdge : Edge = .bottom
    @State private var previousBackgroundHeight : CGFloat = 0
    
    var frontTransactionHeight : CGFloat {
        if viewModel.showOtherPaymentMethods {
            // Payment Method List is shown
            return baseHeight + paymentMethodListHeight
        } else {
            // Quick Payment Screen is shown
            if viewModel.lastPaymentMethod == nil { return baseHeight } else { return baseHeight + quickPaymentHeight }
        }
    }
    
    var backgroundHeight : CGFloat {
        return frontTransactionHeight + blueStripeHeight
    }
    
    var body: some View {
        
        ZStack {
            ColorsUi.APC_DarkBlue
            
            VStack(spacing: 0) {
                HStack {
                    VStack(spacing: 0) {
                        Image("logo-wallet-white", bundle: Bundle.module)
                            .resizable()
                            .edgesIgnoringSafeArea(.all)
                            .frame(width: 83, height: 24)
                            .padding(.top, viewModel.paymentMethodSelected != nil && viewModel.paymentMethodSelected?.name != "appcoins_credits" ? 24 : 0)
                        
                        if viewModel.paymentMethodSelected != nil && viewModel.paymentMethodSelected?.name != "appcoins_credits" {
                            HStack {
                                Image("gift-1", bundle: Bundle.module)
                                    .resizable()
                                    .edgesIgnoringSafeArea(.all)
                                    .frame(width: 15, height: 15)
                                
                                if let bonusCurrency = viewModel.transaction?.bonusCurrency, let bonusAmount = viewModel.transaction?.bonusAmount {
                                    Text(String(format: Constants.purchaseBonus, "\(bonusCurrency)\(String(format: "%.3f", bonusAmount))"))
                                        .font(FontsUi.APC_Caption1_Bold)
                                        .foregroundColor(ColorsUi.APC_White)
                                } else {
                                    HStack(spacing: 0) {
                                        Text(Constants.purchaseBonusFirst)
                                            .font(FontsUi.APC_Caption1_Bold)
                                            .foregroundColor(ColorsUi.APC_White)
                                        Text(" €0.00 ")
                                            .skeleton(with: true)
                                            .font(FontsUi.APC_Caption1_Bold)
                                            .opacity(0.1)
                                            .frame(width: 40, height: 17)
                                        Text(Constants.purchaseBonusSecond)
                                            .font(FontsUi.APC_Caption1_Bold)
                                            .foregroundColor(ColorsUi.APC_White)
                                    }
                                }
                                
                                
                            }.padding(.top, 17)
                            
                            Text(Constants.canSeeBonusText)
                                .font(FontsUi.APC_Caption2)
                                .foregroundColor(ColorsUi.APC_Gray)
                                .padding(.top, 6)
                        }
                        
                        HStack(spacing: 0) {
                            Image("pink-wallet", bundle: Bundle.module)
                                .resizable()
                                .edgesIgnoringSafeArea(.all)
                                .frame(width: 19, height: 16)
                            Text(Constants.walletBalance)
                                .font(FontsUi.APC_Caption1_Bold)
                                .foregroundColor(ColorsUi.APC_Pink)
                                .padding(.leading, 6.22)
                            if let balance = viewModel.transaction?.walletBalance {
                                Text(balance)
                                    .font(FontsUi.APC_Caption1_Bold)
                                    .foregroundColor(ColorsUi.APC_White)
                            } else {
                                Text("0.00€")
                                    .skeleton(with: true)
                                    .font(FontsUi.APC_Caption1_Bold)
                                    .opacity(0.1)
                                    .frame(width: 35, height: 15)
                            }
                        }.padding(.top, viewModel.paymentMethodSelected != nil && viewModel.paymentMethodSelected?.name != "appcoins_credits" ? 24 : 12)
                            .padding(.bottom, viewModel.paymentMethodSelected != nil && viewModel.paymentMethodSelected?.name != "appcoins_credits" ? 24 : 0)
                    }
                    
                }.frame(width: UIScreen.main.bounds.size.width, height: blueStripeHeight)
                
                ZStack {
                    ColorsUi.APC_LightGray
                    
                    VStack(spacing: 0) {
                        
                        // Avatar and purchase
                        HStack(spacing: 0) {
                            VStack(spacing: 0) {
                                Image(uiImage: viewModel.getAppIcon())
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 74, height: 74)
                                    .clipShape(Circle())
                            }
                            
                            VStack(spacing: 0) {
                                if let title = viewModel.transaction?.getTitle() {
                                    Text(title)
                                        .foregroundColor(ColorsUi.APC_Black)
                                        .font(FontsUi.APC_Body_Bold)
                                        .lineLimit(2)
                                        .frame(width: 240, alignment: .leading)
                                } else {
                                    HStack(spacing: 0) {
                                        Text("XXXXX")
                                            .skeleton(with: true)
                                            .frame(width: 125, height: 22, alignment: .leading)
                                        VStack {}.frame(maxWidth: .infinity)
                                    }.frame(maxWidth: .infinity)
                                }
                                
                                
                                HStack(spacing: 0) {
                                    if let amount = viewModel.transaction?.moneyAmount {
                                        Text((Coin(rawValue: viewModel.transaction?.moneyCurrency ?? "")?.symbol ?? "") + String(amount))
                                            .foregroundColor(ColorsUi.APC_Black)
                                            .font(FontsUi.APC_Subheadline_Bold)
                                            .lineLimit(1)
                                            .padding(.trailing, 3)
                                        Text(viewModel.transaction?.moneyCurrency ?? "-")
                                            .foregroundColor(ColorsUi.APC_Black)
                                            .font(FontsUi.APC_Caption1_Bold)
                                            .lineLimit(1)
                                    } else {
                                        HStack(spacing: 0) {
                                            Text("XXXXX")
                                                .skeleton(with: true)
                                                .frame(width: 60, height: 14, alignment: .leading)
                                            VStack {}.frame(maxWidth: .infinity)
                                        }.frame(maxWidth: .infinity)
                                    }
                                }.frame(width: 240, alignment: .bottomLeading)
                                    .padding(.top, 11)
                                
                                if let appcAmount = viewModel.transaction?.appcAmount {
                                    Text("\(String(format: "%.3f", appcAmount)) APPC")
                                        .foregroundColor(ColorsUi.APC_Gray)
                                        .font(FontsUi.APC_Caption2)
                                        .frame(width: 240, alignment: .leading)
                                } else {
                                    HStack(spacing: 0) {
                                        Text("XXXXX")
                                            .skeleton(with: true)
                                            .frame(width: 55, height: 10, alignment: .leading)
                                            .padding(.top, 2)
                                        VStack {}.frame(maxWidth: .infinity)
                                    }.frame(maxWidth: .infinity)
                                }
                            }.frame(width: 240, alignment: .topLeading)
                                .padding(.leading, 16)
                            
                        }.frame(height: 80, alignment: .top)
                            .padding(.top, 24)
                            .padding(.bottom, 22)
                        
                        if viewModel.lastPaymentMethod != nil || viewModel.showOtherPaymentMethods {
                            // Payment methods
                            HStack(spacing: 0) {
                                
                                VStack(spacing: 0) {
                                    
                                    if (!viewModel.showOtherPaymentMethods) {
                                        ZStack {
                                            ColorsUi.APC_White
                                            
                                            HStack(spacing: 0) {
                                                VStack(spacing: 0) {
                                                    if let icon = URL(string: viewModel.lastPaymentMethod?.icon ?? "") {
                                                        PaymentMethodQuickIcon(icon: icon)
                                                    }
                                                }
                                                
                                                VStack(spacing: 0) {
                                                    if viewModel.lastPaymentMethod?.name == "appcoins_credits" {
                                                        Text(viewModel.lastPaymentMethod?.label)
                                                            .foregroundColor(ColorsUi.APC_Black)
                                                            .font(FontsUi.APC_Callout)
                                                            .lineLimit(1)
                                                            .frame(width: 224, alignment: .leading)
                                                            .padding(.bottom, 4)
                                                        
                                                        Text(Constants.earnedEnoughAppcText)
                                                            .foregroundColor(ColorsUi.APC_Gray)
                                                            .font(FontsUi.APC_Caption1)
                                                            .lineLimit(2)
                                                            .frame(width: 224, alignment: .leading)
                                                    } else {
                                                        Text(viewModel.lastPaymentMethod?.label)
                                                            .foregroundColor(ColorsUi.APC_Black)
                                                            .font(FontsUi.APC_Callout)
                                                            .lineLimit(1)
                                                            .frame(width: 224, alignment: .leading)
                                                    }
                                                }.frame(width: 224, alignment: .leading)
                                                    .padding(.leading, 16)
                                            }
                                        }.frame(width: 328, height: 88)
                                            .cornerRadius(13)
                                        
                                        
                                        HStack(spacing: 0) {
                                            HStack(spacing: 0) {
                                                if viewModel.paypalLogOut {
                                                    Button(action: viewModel.logoutPayPal) {
                                                        Text(Constants.logOut)
                                                            .foregroundColor(ColorsUi.APC_DarkGray)
                                                            .font(FontsUi.APC_Caption2_Bold)
                                                    }
                                                }
                                            }.frame(width: 50, alignment: .leading)
                                            
                                            HStack(spacing: 0) {
                                                Button(action: viewModel.showPaymentMethodOptions) {
                                                    Text(Constants.otherPaymentMethodsText)
                                                        .foregroundColor(ColorsUi.APC_Pink)
                                                        .font(FontsUi.APC_Footnote_Bold)
                                                        .lineLimit(1)
                                                        .padding(.trailing, 8)
                                                }
                                                Button(action: viewModel.showPaymentMethodOptions) {
                                                    Image(systemName: "chevron.forward")
                                                        .resizable()
                                                        .edgesIgnoringSafeArea(.all)
                                                        .foregroundColor(ColorsUi.APC_Pink)
                                                        .frame(width: 4, height: 8)
                                                }
                                            }.frame(maxWidth: .infinity, alignment: .trailing)
                                            
                                        }.frame(width: 328)
                                            .padding(.top, 9)
                                    } else {
                                        RadioButtonGroupView(viewModel: viewModel)
                                    }
                                }
                            }
                        }
                        
                        // Buying button
                        Button(action: {
                            DispatchQueue.main.async { viewModel.purchaseState = .processing }
                            viewModel.buy()
                        }) {
                            ZStack {
                                if viewModel.transaction != nil {
                                    ColorsUi.APC_Pink
                                } else {
                                    ColorsUi.APC_Gray
                                }
                                Text(Constants.buyText)
                            }
                        }
                        .disabled(viewModel.transaction == nil)
                        .frame(width: 328, height: 48)
                        .foregroundColor(ColorsUi.APC_White)
                        .cornerRadius(10)
                        .padding(.top, !viewModel.showOtherPaymentMethods ? 37 : 20)
                        
                        Button(action: {
                            viewModel.dismiss()
                        }) {
                            Text(Constants.cancelText)
                                .foregroundColor(ColorsUi.APC_DarkGray)
                                .font(FontsUi.APC_Footnote_Bold)
                                .lineLimit(1)
                        }
                        .padding(.top, 14)
                        .padding(.bottom, 30)
                        
                    }
                }.frame(width: UIScreen.main.bounds.size.width, height: frontTransactionHeight )
                    .cornerRadius(13, corners: [.topLeft, .topRight])
            }
            
        }.frame(width: UIScreen.main.bounds.size.width, height: backgroundHeight)
        .cornerRadius(13, corners: [.topLeft, .topRight])
    // Otherwise (with a regular general animation) the skeletons animation does not work
        .animation(.easeInOut(duration: 0.3), value: viewModel.paymentMethodSelected != nil)
        .animation(.easeInOut(duration: 0.3), value: viewModel.paymentMethodSelected?.name)
        .animation(.easeInOut(duration: 0.3), value: viewModel.showOtherPaymentMethods)
        .animation(.easeInOut(duration: 0.3), value: viewModel.lastPaymentMethod == nil)
    
    
    }
}

