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
    
    @available(iOS 15.0, *)
    internal var LoginEmailConsentsToggle: some View {
        HStack(spacing: 0) {
            Text(Constants.consentEmailBody)
                .font(FontsUi.APC_Footnote)
                .frame(
                    width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 40 : UIScreen.main.bounds.width - 48 - 40,
                    height: Constants.consentEmailBody
                    .height(
                        withConstrainedWidth: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 40 : UIScreen.main.bounds.width - 48 - 40,
                        font: UIFont.systemFont(ofSize: 13, weight: .regular)
                    )
                )
                .multilineTextAlignment(.trailing)
            
            Toggle(isOn: $authViewModel.hasConsentedEmailStorage) {}
                .toggleStyle(SwitchToggleStyle())
                .scaleEffect(0.6)
                .frame(width: 40, height: 20)
        }.frame(height: Constants.consentEmailBody
            .height(
                withConstrainedWidth: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 40 : UIScreen.main.bounds.width - 48 - 40,
                font: UIFont.systemFont(ofSize: 13, weight: .regular)
            )
        )
    }
    
    @available(iOS 15.0, *)
    internal var LoginAcceptTermsToggle: some View {
        HStack(spacing: 0) {
            Text(Constants.acceptTermsBody)
                .font(FontsUi.APC_Footnote)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .frame(
                    width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 40 : UIScreen.main.bounds.width - 48 - 40,
                    height: Constants.acceptTermsBody
                    .height(
                        withConstrainedWidth: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 40 : UIScreen.main.bounds.width - 48 - 40,
                        font: UIFont.systemFont(ofSize: 13, weight: .regular)
                    )
                )
                .multilineTextAlignment(.trailing)
            
            Toggle(isOn: $authViewModel.hasConsentedEmailStorage) {}
                .toggleStyle(SwitchToggleStyle())
                .scaleEffect(0.6)
                .frame(width: 40, height: 20)
        }.frame(height: Constants.acceptTermsBody
            .height(
                withConstrainedWidth: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 40 : UIScreen.main.bounds.width - 48 - 40,
                font: UIFont.systemFont(ofSize: 13, weight: .regular)
            )
        )
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
            GoogleLoginButton()
            
            VStack{}.frame(height: 16)
            
            LoginFormSeparator()
            
            VStack{}.frame(height: 16)
            
            MagicLinkEmailInput()
            
            VStack{}.frame(height: 16)
            
            if #available(iOS 15.0, *) {
                LoginEmailConsentsToggle
                
                VStack{}.frame(height: 8)
                
                LoginAcceptTermsToggle
            }
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48)
    }
}
