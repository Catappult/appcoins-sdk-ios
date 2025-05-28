//
//  DeleteAccountSentView.swift
//  AppCoinsSDK
//
//  Created by aptoide on 22/05/2025.
//

import SwiftUI

internal struct DeleteAccountSentView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var deleteAccountCounterLabelHeight: CGFloat {
        String(format: Constants.resendInTime, "30")
            .height(
                withConstrainedWidth: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48,
                font: UIFont.systemFont(ofSize: 15, weight: .regular)
            )
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
            HStack{}.frame(maxHeight: .infinity)
            HStack{}.frame(maxHeight: .infinity) // This will make the top spacing take double the space as the middle spacing
            
            DeleteAccountImage()
            
            HStack{}.frame(height: 16)
            
            DeleteAccountLabel()
            
            HStack{}.frame(maxHeight: .infinity)
            
            VStack(spacing: 0) {
                if authViewModel.retryDeleteIn != 0 {
                    DeleteAccountCounter()
                    
                    HStack{}.frame(height: 8)
                    
                    DeleteAccountCounterLabel(deleteAccountCounterLabelHeight: deleteAccountCounterLabelHeight)
                }
            }.frame(height: 32 + deleteAccountCounterLabelHeight)
            
            HStack{}.frame(height: 16)
            
            ResendDeleteAccountButton()
            
            HStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.width, height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : nil)
        .background(ColorsUi.APC_BottomSheet_LightGray_Background)
        .ignoresSafeArea(.all)
        
    }
}

