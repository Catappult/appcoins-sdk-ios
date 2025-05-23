//
//  LoggedOutSuccessSignInLabel.swift
//
//
//  Created by aptoide on 03/01/2025.
//

import SwiftUI

internal struct LoggedOutSuccessSignInLabel: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    internal var body: some View {
        if case let .regular(transaction) = transactionViewModel.transaction {
            Text(String(format: Constants.signInToRedeem, "\(transaction.bonusCurrency.sign)\(String(format: "%.2f", transaction.bonusAmount))"))
                .font(FontsUi.APC_Footnote)
                .foregroundColor(ColorsUi.APC_Black)
                .frame(
                    width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48,
                    height: String(format: Constants.signInToRedeem, "\(transaction.bonusCurrency.sign)\(String(format: "%.2f", transaction.bonusAmount))")
                        .height(
                            withConstrainedWidth: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48,
                            font: UIFont.systemFont(ofSize: 13, weight: .regular))
                )
                .multilineTextAlignment(.center)
        }
    }
}
