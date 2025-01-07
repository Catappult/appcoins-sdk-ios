//
//  LoggedInSuccessBonusEarnedLabel.swift
//
//
//  Created by aptoide on 03/01/2025.
//

import SwiftUI

internal struct LoggedInSuccessBonusEarnedLabel: View {
    
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    internal var body: some View {
        HStack(spacing: 0) {
            if transactionViewModel.hasBonus {
                Text(String(format: Constants.bonusReceived, "\(transactionViewModel.transaction?.bonusCurrency.sign ?? "")\(String(format: "%.2f", transactionViewModel.transaction?.bonusAmount ?? 0.0))"))
                    .font(FontsUi.APC_Subheadline_Bold)
                    .foregroundColor(ColorsUi.APC_Pink)
                    .frame(alignment: .bottom)
            }
        }.frame(height: 17)
    }
}
