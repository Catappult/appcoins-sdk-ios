//
//  FocusedMagicLink.swift
//
//
//  Created by aptoide on 30/12/2024.
//

import SwiftUI

internal struct FocusedMagicLink: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    internal var body: some View {
        if #available(iOS 17, *) {
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ColorsUi.APC_White)
                        .stroke(!authViewModel.isMagicLinkEmailValid ? Color.red : .clear, lineWidth: 1)
                        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
                    
                    HStack(spacing: 0) {
                        Text(Constants.emailLabel)
                        
                        VStack{}.frame(width: 8)
                        
                        FocusableTextField(authViewModel: authViewModel, placeholder: Constants.yourEmail, text: $authViewModel.magicLinkEmail)
                        
                    }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 32 : UIScreen.main.bounds.width - 48 - 32)
                }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
            }
        }
    }
}
