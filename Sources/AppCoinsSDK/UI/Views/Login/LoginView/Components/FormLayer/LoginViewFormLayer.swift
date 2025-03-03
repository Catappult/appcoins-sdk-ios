//
//  LoginViewFormLayer.swift
//  
//
//  Created by aptoide on 30/12/2024.
//

import SwiftUI

internal struct LoginViewFormLayer: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var body: some View {
        VStack(spacing: 0) {
            OverflowAnimationWrapper(height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 - 86 - 72 : 420 - 86 - 72, offset: 72) {
                if viewModel.orientation == .landscape && authViewModel.isTextFieldFocused {
                    FocusedMagicLink()
                } else {
                    LoginForm()
                }
            }
            
            HStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 63 : 86)
        }
    }
}
