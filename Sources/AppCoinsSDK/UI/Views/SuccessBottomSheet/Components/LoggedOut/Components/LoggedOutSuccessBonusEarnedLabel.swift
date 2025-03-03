//
//  LoggedOutSuccessBonusEarnedLabel.swift
//
//
//  Created by aptoide on 03/01/2025.
//

import SwiftUI

internal struct LoggedOutSuccessBonusEarnedLabel: View {
    
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    internal var body: some View {
        HStack(spacing: 0) {
            if transactionViewModel.hasBonus {
                Image("gift-pink", bundle: Bundle.APPCModule)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: 14.7, height: 16)
                
                VStack{}.frame(width: 5)
                
                Text(String(format: Constants.bonusReceived, "\(transactionViewModel.transaction?.bonusCurrency.sign ?? "")\(String(format: "%.2f", transactionViewModel.transaction?.bonusAmount ?? 0.0))"))
                    .font(FontsUi.APC_Subheadline_Bold)
                    .foregroundColor(ColorsUi.APC_Black)
            }
        }.frame(height: 24)
    }
}
