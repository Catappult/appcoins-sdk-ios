//
//  LoginForm.swift
//  
//
//  Created by aptoide on 30/12/2024.
//

import SwiftUI

internal struct LoginForm: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var body: some View {
        VStack(spacing: 0) {
            GoogleLoginButton()
            
            VStack{}.frame(height: 16)
            
            LoginFormSeparator()
            
            VStack{}.frame(height: 16)
            
            MagicLinkEmailInput()
            
            VStack{}.frame(height: 16)
            
            if #available(iOS 15.0, *) {
                LoginEmailConsentsToggle()
                
                VStack{}.frame(height: 8)
                
                LoginAcceptTermsToggle()
                
                VStack{}.frame(height: 8)
            }
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48)
    }
}
