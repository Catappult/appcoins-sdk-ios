//
//  GamificationBanner.swift
//
//
//  Created by Graciano Caldeira on 29/07/2024.
//

import SwiftUI

struct GamificationBanner: View {
    
    @ObservedObject var transactionViewModel: TransactionViewModel
//    var flavor: Flavor
    var bonusValue: Double = 10
    
    var body: some View {
        VStack(spacing: 0) {
            Image("logo-wallet-white", bundle: Bundle.module)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .frame(width: 83, height: 24)
                .padding(.top, transactionViewModel.paymentMethodSelected != nil && transactionViewModel.paymentMethodSelected?.name != Method.appc.rawValue ? 24 : 0)
            
            if transactionViewModel.paymentMethodSelected != nil && transactionViewModel.paymentMethodSelected?.name != Method.appc.rawValue {
                HStack {
                    Image("gift-1", bundle: Bundle.module)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 15, height: 15)
                    
                    if let bonusCurrency = transactionViewModel.transaction?.bonusCurrency, let bonusAmount = transactionViewModel.transaction?.bonusAmount {
                        Text(String(format: Constants.purchaseBonus, "\(bonusCurrency)\(String(format: "%.3f", bonusAmount))"))
                            .font(FontsUi.APC_Caption1_Bold)
                            .foregroundColor(ColorsUi.APC_White)
                            .frame(height: 16)
                    } else {
                        HStack(spacing: 0) {
                            Text("")
                                .skeleton(with: true)
                                .font(FontsUi.APC_Caption1_Bold)
                                .opacity(0.1)
                                .frame(width: 40, height: 17)
                        }
                    }
                }.padding(.top, 17)
                
                Text(Constants.canSeeBonusText)
                    .font(FontsUi.APC_Caption2)
                    .foregroundColor(ColorsUi.APC_Gray)
                    .frame(height: 13)
                    .padding(.top, 6)
            }
            
            HStack(spacing: 0) {
                Image("pink-wallet", bundle: Bundle.module)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: 19, height: 16)
                
                if let balance = transactionViewModel.transaction?.walletBalance {
                    StyledText(
                        String(format: Constants.walletBalance, "*\(balance)*"),
                        textStyle: FontsUi.APC_Caption1_Bold,
                        boldStyle: FontsUi.APC_Caption1_Bold,
                        textColorRegular: ColorsUi.APC_Pink,
                        textColorBold: ColorsUi.APC_White)
                        .padding(.leading, 6.22)
                } else {
                    Text(String(format: Constants.walletBalance, ""))
                        .font(FontsUi.APC_Caption1_Bold)
                        .foregroundColor(ColorsUi.APC_Pink)
                        .padding(.leading, 6.22)
                    
                    Text("")
                        .skeleton(with: true)
                        .font(FontsUi.APC_Caption1_Bold)
                        .opacity(0.1)
                        .frame(width: 35, height: 15)
                }
                
            }.padding(.top, transactionViewModel.paymentMethodSelected != nil && transactionViewModel.paymentMethodSelected?.name != Method.appc.rawValue ? 24 : 12)
                .padding(.bottom, transactionViewModel.paymentMethodSelected != nil && transactionViewModel.paymentMethodSelected?.name != Method.appc.rawValue ? 24 : 0)
        }
        
    }
}
