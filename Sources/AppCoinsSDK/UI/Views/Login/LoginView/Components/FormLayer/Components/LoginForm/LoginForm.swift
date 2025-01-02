//
//  LoginForm.swift
//  
//
//  Created by aptoide on 30/12/2024.
//

import SwiftUI

internal struct LoginForm: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    internal var body: some View {
        VStack(spacing: 0) {
            VStack{}.frame(height: viewModel.orientation != .landscape ? 32 : 0)
            
            GoogleLoginButton()
            
            VStack{}.frame(height: 36)
            
            LoginFormSeparator()
            
            VStack{}.frame(height: 16)
            
            MagicLinkEmailInput()
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48)
    }
}
