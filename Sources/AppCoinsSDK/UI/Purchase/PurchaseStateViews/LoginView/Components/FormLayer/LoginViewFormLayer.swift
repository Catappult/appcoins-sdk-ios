//
//  File.swift
//  
//
//  Created by aptoide on 30/12/2024.
//

import SwiftUI

struct LoginViewFormLayer: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    var body: some View {
        VStack(spacing: 0) {
            PurchaseViewWrapper(height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 - 78 - 72 : 420 - 78 - 72, offset: 72) {
                if viewModel.orientation == .landscape && authViewModel.isTextFieldFocused {
                    FocusedMagicLink()
                } else {
                    LoginForm()
                }
            }
            
            HStack{}.frame(height: 78)
        }
    }
}
