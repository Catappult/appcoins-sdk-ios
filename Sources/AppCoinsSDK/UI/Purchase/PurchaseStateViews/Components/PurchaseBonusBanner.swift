//
//  PurchaseBonusBanner.swift
//
//
//  Created by Graciano Caldeira on 14/10/2024.
//

import SwiftUI

struct PurchaseBonusBanner: View {
    
    @ObservedObject var viewModel: BottomSheetViewModel
    @ObservedObject var transactionViewModel: TransactionViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if transactionViewModel.hasBonus {
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
                
                HStack(spacing: 0) {
                    Image("white-wallet", bundle: Bundle.module)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 16, height: 14)
                    
                    if let balanceCurrency = transactionViewModel.transaction?.balanceCurrency.sign, let balanceValue = transactionViewModel.transaction?.balanceAmount {
                        
                        VStack {}.frame(width: 6.22)
                        
                        StyledText(
                            String(format: Constants.walletBalance, "*\(balanceCurrency)\(String(format: "%.2f", balanceValue))*"),
                            textStyle: FontsUi.APC_Caption1_Bold,
                            boldStyle: FontsUi.APC_Caption1_Bold,
                            textColorRegular: ColorsUi.APC_White,
                            textColorBold: ColorsUi.APC_White)
                        
                    } else {
                        
                        VStack {}.frame(width: 6.22)
                        
                        Text(String(format: Constants.walletBalance, ""))
                            .font(FontsUi.APC_Caption1_Bold)
                            .foregroundColor(ColorsUi.APC_Pink)
                        
                        Text("")
                            .skeleton(with: true)
                            .font(FontsUi.APC_Caption1_Bold)
                            .opacity(0.1)
                            .frame(width: 35, height: 15)
                    }
                }
                
                VStack {}.frame(height: 10)
            } else {
                HStack {
                    Image("gift-gray", bundle: Bundle.module)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 16, height: 16)
                    
                    Text(Constants.bonusNotAvailableText)
                        .font(FontsUi.APC_Caption1_Bold)
                        .foregroundColor(ColorsUi.APC_BottomSheet_APPC)
                }
            }
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 56)
        .background(transactionViewModel.hasBonus ? ColorsUi.APC_DarkBlue : ColorsUi.APC_BonusBannerBackground)
        .animation(.easeInOut(duration: 0.2))
        .cornerRadius(12)
    }
}
