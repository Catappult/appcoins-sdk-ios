//
//  ManageAccountBalanceBanner.swift
//
//
//  Created by aptoide on 02/01/2025.
//

import Foundation
import SwiftUI

internal struct ManageAccountBalanceBanner: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var body: some View {
        if case let .regular(transaction) = transactionViewModel.transaction {
            HStack(spacing: 0) {
                
                VStack{}.frame(width: 16)
                
                HStack {
                    Image("pink-wallet", bundle: Bundle.APPCModule)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 16, height: 14)
                    
                    StyledText(
                        String(format: Constants.yourBalance, "*\(transaction.balanceCurrency.sign)\(String(format: "%.2f", transaction.balanceAmount))*"),
                        textStyle: FontsUi.APC_Caption1_Bold,
                        boldStyle: FontsUi.APC_Caption1_Bold,
                        textColorRegular: ColorsUi.APC_Pink,
                        textColorBold: ColorsUi.APC_Black)
                }.frame(maxWidth: .infinity, alignment: .leading)
            
                VStack{}.frame(width: 16)
            }
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 40)
            .background(ColorsUi.APC_LightPink)
            .cornerRadius(12)
        }
    }
}
