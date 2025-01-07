//
//  LoggedInSuccessNewWalletBalanceLabel.swift
//
//
//  Created by aptoide on 03/01/2025.
//

import SwiftUI

internal struct LoggedInSuccessNewWalletBalanceLabel: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    internal var body: some View {
        HStack(spacing: 0) {
            Image("pink-wallet", bundle: Bundle.APPCModule)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .frame(width: 19, height: 16)
            
            VStack{}.frame(width: 6.22)
            
            if let balance = viewModel.finalWalletBalance {
                StyledText(
                    String(format: Constants.yourBalance, "*\(balance)*"),
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
        }
    }
}
