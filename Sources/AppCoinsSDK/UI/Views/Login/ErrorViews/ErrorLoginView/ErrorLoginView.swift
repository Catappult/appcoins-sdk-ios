//
//  ErrorLoginView.swift
//
//
//  Created by aptoide on 20/12/2024.
//

import SwiftUI

internal struct ErrorLoginView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @State private var toast: FancyToast? = nil
    
    internal var body: some View {
        VStack(spacing: 0) {
            HStack{}.frame(maxHeight: .infinity)
            
            LoginErrorExclamationImageAndLabel()
            
            HStack{}.frame(maxHeight: .infinity)
            
            TryAgainButton()
            
            HStack{}.frame(height: 19)
            
            LoginErrorSupportButton(toast: $toast)
            
            HStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
        }.frame(maxWidth: .infinity, alignment: .top)
        .toastView(toast: $toast)
    }
}
