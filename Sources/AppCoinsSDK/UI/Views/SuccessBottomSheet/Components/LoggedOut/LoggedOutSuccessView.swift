//
//  LoggedOutSuccessView.swift
//  
//
//  Created by aptoide on 03/01/2025.
//

import SwiftUI

internal struct LoggedOutSuccessView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    internal var body: some View {
        Button(action: { viewModel.dismiss() }) {
            VStack(spacing: 0) {
                VStack{}.frame(height: viewModel.orientation == .landscape ? 8 : 18)
                
                LoggedOutSuccessImageAndLabel()
                
                VStack{}.frame(height: 11)
                
                LoggedOutSuccessBonusEarnedLabel()
                
                VStack{}.frame(maxHeight: .infinity)
                
                LoggedOutSuccessBonusGiftImage()
                
                VStack{}.frame(maxHeight: .infinity)
                
                LoggedOutSuccessSignInLabel()
                
                VStack{}.frame(height: 8)
                
                LoggedOutSuccessSignInButton()
                
                HStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
            }.background(
                Image("horizontal-bonus-background", bundle: Bundle.APPCModule)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(
                        width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width,
                        height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : 420
                    )
            )
        }
    }
}
