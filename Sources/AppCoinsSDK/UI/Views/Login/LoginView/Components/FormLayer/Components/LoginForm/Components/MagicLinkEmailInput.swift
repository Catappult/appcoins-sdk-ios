//
//  MagicLinkEmailInput.swift
//  
//
//  Created by aptoide on 30/12/2024.
//

import SwiftUI

internal struct MagicLinkEmailInput: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var inputField: some View {
        ZStack {
            if #available(iOS 17.0, *) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(ColorsUi.APC_White)
                    .stroke(!authViewModel.isMagicLinkEmailValid ? Color.red : .clear, lineWidth: 1)
                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
            }
            
            HStack(spacing: 0) {
                
                Text(Constants.emailLabel)
                
                VStack{}.frame(width: 8)
                
                if viewModel.orientation == .landscape {
                    TextField(Constants.yourEmail, text: $authViewModel.magicLinkEmail)
                } else {
                    TextField(Constants.yourEmail, text: $authViewModel.magicLinkEmail)
                }
            }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 32 : UIScreen.main.bounds.width - 48 - 32, alignment: .leading)
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
        .onTapGesture {
            if viewModel.orientation == .landscape {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.4)) { authViewModel.showFocusedTextField() }
                }
            }
        }
    }
    
    internal var errorMessage: some View {
        VStack(spacing: 0) {
            VStack{}.frame(height: 4)
            
            Text(Constants.invalidEmail)
                .font(FontsUi.APC_Footnote_Bold)
                .foregroundColor(Color.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 20)
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
            inputField
            if !authViewModel.isMagicLinkEmailValid { errorMessage }
        }.animation(.easeInOut(duration: 0.2))
    }
}
