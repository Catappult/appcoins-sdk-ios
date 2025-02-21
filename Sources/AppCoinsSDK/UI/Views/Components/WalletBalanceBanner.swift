//
//  WalletBalanceBanner.swift
//
//
//  Created by aptoide on 02/01/2025.
//

import Foundation
import SwiftUI

internal struct WalletBalanceBanner: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var body: some View {
        HStack(spacing: 0) {
            
            VStack{}.frame(width: 16)
                
            HStack {
                Image("pink-wallet", bundle: Bundle.APPCModule)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: 16, height: 14)
                
                if let balanceCurrency = transactionViewModel.transaction?.balanceCurrency.sign, let balanceValue = transactionViewModel.transaction?.balanceAmount {
                    StyledText(
                        String(format: Constants.yourBalance, "*\(balanceCurrency)\(String(format: "%.2f", balanceValue))*"),
                        textStyle: FontsUi.APC_Caption1_Bold,
                        boldStyle: FontsUi.APC_Caption1_Bold,
                        textColorRegular: ColorsUi.APC_Pink,
                        textColorBold: ColorsUi.APC_Black)
                } else {
                    Text(String(format: Constants.yourBalance, ""))
                        .font(FontsUi.APC_Caption1_Bold)
                        .foregroundColor(ColorsUi.APC_Pink)
                    
                    Text("")
                        .skeleton(with: true)
                        .font(FontsUi.APC_Caption1_Bold)
                        .opacity(0.1)
                        .frame(width: 35, height: 15)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: authViewModel.showLogoutAlert) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .resizable()
                    .foregroundColor(ColorsUi.APC_Black)
                    .frame(width: 16, height: 18)
            }
            
            VStack{}.frame(width: 25)
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 40)
        .background(ColorsUi.APC_LightPink)
        .animation(.easeInOut(duration: 0.2))
        .cornerRadius(12)
    }
}
