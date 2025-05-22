//
//  ManageAccountView.swift
//  AppCoinsSDK
//
//  Created by aptoide on 21/05/2025.
//

import SwiftUI

internal struct ManageAccountView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var authViewModel: AuthViewModel
    
    internal var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(Constants.manageAccountText)
                    .font(FontsUi.APC_Callout_Bold)
                    .foregroundColor(ColorsUi.APC_Black)
                    .frame(height: 21)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                CloseButton(action: viewModel.dismissManageAccountSheet)
            }
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 72)
            
            VStack{}.frame(height: 8)
            
            // Content
            VStack(spacing: 0) {
                WalletBalanceBanner()
                
                VStack{}.frame(maxHeight: .infinity)
                
                Button(action: authViewModel.showLogoutAlert) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(ColorsUi.APC_White)
                        Text(Constants.logOut)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                .foregroundColor(ColorsUi.APC_Black)

                Button(action: authViewModel.showDeleteAccountAlert) {
                    Text(Constants.deleteAccountText)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 40)
                .foregroundColor(ColorsUi.APC_Red)
                
                VStack{}.frame(height: Utils.bottomSafeAreaHeight + 8)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.width, height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : nil)
        .background(ColorsUi.APC_BottomSheet_LightGray_Background)
        .ignoresSafeArea(.all)
    }
}
