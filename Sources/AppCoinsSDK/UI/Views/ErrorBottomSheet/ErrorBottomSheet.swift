//
//  ErrorBottomSheet.swift
//
//
//  Created by aptoide on 08/03/2023.
//

import Foundation
import SwiftUI

internal struct ErrorBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @State private var toast: FancyToast? = nil
    
    internal var body: some View {
        ZStack {
            ColorsUi.APC_BottomSheet_LightGray_Background
            VStack(spacing: 0) {
                DismissHeader()
                
                VStack{}.frame(maxHeight: .infinity)
                
                ErrorExclamationImageAndLabel()
                
                VStack{}.frame(maxHeight: .infinity)
                
                ErrorSupportButton(toast: $toast)
                
                VStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
            }
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width, height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : 420)
        .cornerRadius(13, corners: [.topLeft, .topRight])
        .toastView(toast: $toast)
    }
}
