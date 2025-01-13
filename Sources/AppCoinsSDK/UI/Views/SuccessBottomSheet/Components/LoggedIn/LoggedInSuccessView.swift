//
//  LoggedInSuccessView.swift
//
//
//  Created by aptoide on 03/01/2025.
//

import SwiftUI

internal struct LoggedInSuccessView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    internal var body: some View {
        Button(action: { viewModel.dismiss() }) {
            VStack(spacing: 0) {
                VStack{}.frame(height: viewModel.orientation == .landscape ? 32 : 50)
                
                LoggedInSuccessImageAndLabel()
                
                VStack{}.frame(height: 30)
                
                LoggedInSuccessBonusEarnedLabel()
                
                VStack{}.frame(height: 20)
                
                LoggedInSuccessNewWalletBalanceLabel()
                
                VStack{}.frame(maxHeight: .infinity)
            }
        }
    }
}
