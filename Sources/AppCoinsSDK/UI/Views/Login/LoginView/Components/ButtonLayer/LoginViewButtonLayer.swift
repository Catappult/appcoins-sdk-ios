//
//  LoginViewButtonLayer.swift
//  
//
//  Created by aptoide on 30/12/2024.
//

import SwiftUI

internal struct LoginViewButtonLayer: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var body: some View {
        if #available(iOS 16.0, *) {
            VStack(spacing: 0) {
                HStack{}.frame(maxHeight: .infinity)
                
                Button(action: {
                    if authViewModel.validateEmail() { authViewModel.sendMagicLink() }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(ColorsUi.APC_Pink)
                        
                        if authViewModel.isSendingMagicLink {
                            ProgressView().tint(ColorsUi.APC_White)
                        } else {
                            Text(Constants.continueText)
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                .foregroundColor(ColorsUi.APC_White)
                
                VStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
            }
        }
    }
}


