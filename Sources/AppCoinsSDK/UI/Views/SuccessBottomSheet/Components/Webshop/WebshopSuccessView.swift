//
//  WebshopSuccessView.swift
//  
//
//  Created by aptoide on 09/05/2025.
//

import SwiftUI

internal struct WebshopSuccessView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    internal var body: some View {
        Button(action: { viewModel.dismiss() }) {
            VStack(spacing: 0) {
                VStack{}.frame(maxHeight: .infinity)
                
                WebshopSuccessImageAndLabel()
                
                VStack{}.frame(maxHeight: .infinity)
            }
        }
    }
}
