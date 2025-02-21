//
//  PayingViewButtonLayer.swift
//  
//
//  Created by aptoide on 27/12/2024.
//

import SwiftUI

internal struct PayingViewButtonLayer: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    internal var body : some View {
        VStack(spacing: 0) {
            HStack{}.frame(maxHeight: .infinity)
            
            // Buying button
            Button(action: {
                viewModel.buy()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(transactionViewModel.transaction != nil ? ColorsUi.APC_Pink : ColorsUi.APC_Gray)
                    Text(Constants.buyText)
                }
            }
            .disabled(transactionViewModel.transaction == nil)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
            .foregroundColor(ColorsUi.APC_White)
            
            VStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
        }
    }
}
