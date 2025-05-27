//
//  LoggedOutSuccessSignInButton.swift
//
//
//  Created by aptoide on 03/01/2025.
//

import SwiftUI

internal struct LoggedOutSuccessSignInButton: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var body: some View {
        Button(action: {
            authViewModel.reset()
            viewModel.setPurchaseState(newState: .login)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(ColorsUi.APC_Pink)
                
                Text(Constants.signInButton)
                    .foregroundColor(ColorsUi.APC_White)
            }
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
    }
}
