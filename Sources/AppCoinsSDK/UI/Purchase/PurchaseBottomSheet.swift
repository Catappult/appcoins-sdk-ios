//
//  PurchaseBottomSheet.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI
import URLImage

struct PurchaseBottomSheet: View {
    
    let transaction: TransactionAlertUi?
    let buyAction: () -> Void
    let dismissAction: () -> Void
    let setPaymentMethod: (Int) -> Void
    @State var showPaymentMethods = false
    
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
                            .padding(.top, 24)
                        
                        HStack {
                            Image("gift-1", bundle: Bundle.module)
                                .resizable()
                                .edgesIgnoringSafeArea(.all)
                                .frame(width: 15, height: 15)
                            
//                            Text("Purchase Bonus: "+(Coin(rawValue: transaction?.bonusCurrency ?? "")?.symbol ?? "")+String(transaction?.bonusAmount ?? 0.0)+" in APPC Credits")
//                                .font(FontsUi.APC_Caption1_Bold)
                            Text("Purchase Bonus: 0.05 in APPC Credits")
                                .font(FontsUi.APC_Caption1_Bold)
                                .foregroundColor(ColorsUi.APC_White)
                                
                        }.padding(.top, 17)
                        
                        
                        Text("You can see this bonus in your next purchase.")
                            .font(FontsUi.APC_Caption2)
                            .foregroundColor(ColorsUi.APC_White)
                            .padding(.top, 6)
                            .padding(.bottom, 12)
                    }
                    
                }.frame(width: UIScreen.main.bounds.size.width, height: 484-372)
                
                ZStack {
                    ColorsUi.APC_LightGray
                    
                    VStack(spacing: 0) {
                        
                        // Avatar and purchase
                        HStack(spacing: 0) {
                            VStack(spacing: 0) {
                                if let avatarURL = URL(string: transaction?.avatarUrl ?? "") {
                                    URLImage(avatarURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 74, height: 74)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            
                            VStack(spacing: 0) {
                                Text(transaction?.getTitle() ?? "")
                                    .foregroundColor(ColorsUi.APC_Black)
                                    .font(FontsUi.APC_Body_Bold)
                                    .lineLimit(2)
                                    .frame(width: 240, alignment: .leading)
                                
                                HStack(spacing: 0) {
//                                    Text((Coin(rawValue: transaction?.moneyCurrency ?? "")?.symbol ?? "") + (transaction?.moneyAmount.currency ?? ""))
                                    Text("€")
                                        .foregroundColor(ColorsUi.APC_Black)
                                        .font(FontsUi.APC_Subheadline_Bold)
                                        .lineLimit(1)
                                        .padding(.trailing, 3)
                                    Text(transaction?.moneyCurrency ?? "-")
                                        .foregroundColor(ColorsUi.APC_Black)
                                        .font(FontsUi.APC_Caption1_Bold)
                                        .lineLimit(1)
                                }.frame(width: 240, alignment: .bottomLeading)
                                    .padding(.top, 11)
                                
//                                Text("\(transaction!.appcAmount.currency) APPC")
                                Text("\(transaction?.appcAmount ?? 0.0) APPC")
                                    .foregroundColor(ColorsUi.APC_Gray)
                                    .font(FontsUi.APC_Caption2)
                                    .frame(width: 240, alignment: .leading)
                            }.frame(width: 240, alignment: .topLeading)
                            .padding(.leading, 16)
                        
                        }.frame(height: 80, alignment: .top)
                            .padding(.top, 24)
                            .padding(.bottom, 22)
                        
                        // Payment methods
                        HStack(spacing: 0) {
                            
                            VStack(spacing: 0) {
                                
                                if (!showPaymentMethods) {
                                    ZStack {
                                        ColorsUi.APC_White
                                        
                                        HStack(spacing: 0) {
                                            VStack(spacing: 0) {
                                                Image("appc-payment-method-pink", bundle: Bundle.module)
                                                    .resizable()
                                                    .edgesIgnoringSafeArea(.all)
                                                    .frame(width: 48, height: 48)
                                            }
                                            VStack(spacing: 0) {
                                                Text("AppCoins Credits")
                                                    .foregroundColor(ColorsUi.APC_Black)
                                                    .font(FontsUi.APC_Callout)
                                                    .lineLimit(1)
                                                    .frame(width: 224, alignment: .leading)
                                                    .padding(.bottom, 4)
                                                
                                                Text("You earned enough AppCoins Credits for this purchase. Enjoy!")
                                                    .foregroundColor(ColorsUi.APC_Gray)
                                                    .font(FontsUi.APC_Caption1)
                                                    .lineLimit(2)
                                                    .frame(width: 224, alignment: .leading)
                                            }.frame(width: 224, alignment: .leading)
                                                .padding(.leading, 16)
                                        }
                                    }.frame(width: 328, height: 88)
                                        .cornerRadius(13)
                                        //.padding(16)
                                
                                    Button(action: {showPaymentMethods.toggle()}) {
                                        HStack(spacing: 0) {
                                            Text("Other payment methods")
                                                .foregroundColor(ColorsUi.APC_Pink)
                                                .font(FontsUi.APC_Footnote_Bold)
                                                .lineLimit(1)
                                                .frame(width: 316, alignment: .trailing)
                                                .padding(.trailing, 8)
                                            
                                            Image(systemName: "chevron.forward")
                                                .resizable()
                                                .edgesIgnoringSafeArea(.all)
                                                .foregroundColor(ColorsUi.APC_Pink)
                                                .frame(width: 4, height: 8)
                                                
                                        }.frame(width: 328, alignment: .trailing)
                                            .padding(.top, 9)
                                    }
                                } else {
                                    
//                                    RadioButtonGroupView(
//                                        setPaymentMethod: setPaymentMethod,
//                                        options: transaction?.paymentMethods.map { PaymentMethodView(icon: $0.icon, name: $0.label, disabled: $0.label != "AppCoins Credits") } ?? []
//                                    ).onAppear{
//                                        for pm in transaction?.paymentMethods ?? [] { pm.label }
//                                    }
                                }
                            }
                            
                        }
                        
                        // Buying button
                        
                        Button(action: buyAction) {
                            Text("Buy")
                        }
                        .frame(width: 328, height: 48)
                        .background(ColorsUi.APC_Pink)
                        .foregroundColor(ColorsUi.APC_White)
                        .cornerRadius(10)
                        .padding(.top, !showPaymentMethods ? 37 : 20)
                        
                        Button(action: {
//                            MainViewModel.returnToGame((transaction?.domain)!, .failed)
                            dismissAction()
                        }) {
                            Text("Cancel")
                                .foregroundColor(ColorsUi.APC_DarkGray)
                                .font(FontsUi.APC_Footnote_Bold)
                                .lineLimit(1)
                        }
                        .padding(.top, 14)
                        .padding(.bottom, 30)
                     
                    }
                }.frame(width: UIScreen.main.bounds.size.width, height: !showPaymentMethods ? 372 : 256+CGFloat(44*(transaction?.paymentMethods.count ?? 0)))
                .cornerRadius(13, corners: [.topLeft, .topRight])
            }
            
            
        }.frame(width: UIScreen.main.bounds.size.width, height: !showPaymentMethods ? 484 : 256+112+CGFloat(44*(transaction?.paymentMethods.count ?? 0)))
            .cornerRadius(13, corners: [.topLeft, .topRight])
        
        
    }
}
