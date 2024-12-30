//
//  File.swift
//  
//
//  Created by aptoide on 30/12/2024.
//

import SwiftUI

internal struct GoogleLoginButton: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var body: some View {
        if #available(iOS 17.0, *) {
            Button(action: { authViewModel.loginWithGoogle() }) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(ColorsUi.APC_White)
                        .stroke(ColorsUi.APC_Black, lineWidth: 1)
                        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                    
                    HStack(spacing: 0) {
                        Image("google-logo", bundle: Bundle.APPCModule)
                            .resizable()
                            .frame(width: 13, height: 13)
                        
                        VStack{}.frame(width: 8)
                        
                        Text(Constants.signInWithGoogleText)
                            .font(FontsUi.APC_Body)
                    }
                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                }
            }
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
            .buttonStyle(flatButtonStyle())
        }
    }
}
