//
//  SuccessBottomSheet.swift
//  
//
//  Created by aptoide on 08/03/2023.
//

import SwiftUI

internal struct SuccessBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var body: some View {
        ZStack {
            ColorsUi.APC_BottomSheet_LightGray_Background
            
            if authViewModel.isLoggedIn {
                LoggedInSuccessView()
            } else {
                LoggedOutSuccessView()
            }
            
            VStack(spacing: 0) {
                DismissHeader()
                HStack{}.frame(maxHeight: .infinity)
            }
        }.frame(
            width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width,
            height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : 420
        )
        .cornerRadius(13, corners: [.topLeft, .topRight])
        .offset(y: authViewModel.isLoggedIn ? 0 : viewModel.successAnimation ? 0 : 420)
        .transition(authViewModel.isLoggedIn ? .identity : viewModel.successAnimation ? .identity : .move(edge: .top))
        .animation(.easeOut(duration: 0.5))
    }
}
