//
//  ResendDeleteAccountButton.swift
//
//
//  Created by aptoide on 03/01/2025.
//

import SwiftUI

internal struct ResendDeleteAccountButton: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var body: some View {
        Button(action: {
            authViewModel.deleteAccount()
        }) {
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(authViewModel.retryDeleteIn != 0 ? ColorsUi.APC_BonusBannerBackground : ColorsUi.APC_Pink)
                if authViewModel.isSendingDelete {
                    if #available(iOS 16.0, *) { ProgressView().tint(ColorsUi.APC_White) }
                } else {
                    Text(Constants.resendEmail)
                        .foregroundColor(authViewModel.retryDeleteIn != 0 ? ColorsUi.APC_LoginIcon : ColorsUi.APC_White)
                }
            }
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
        .disabled(authViewModel.retryDeleteIn != 0)
    }
}
