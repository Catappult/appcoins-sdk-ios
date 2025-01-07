//
//  File.swift
//  
//
//  Created by aptoide on 06/01/2025.
//

import SwiftUI

internal struct NoInternetLoginView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @State private var toast: FancyToast? = nil
    
    internal var body: some View {
        VStack(spacing: 0) {
            HStack{}.frame(maxHeight: .infinity)
            
            LoginNoInternetImageAndLabel()
            
            HStack{}.frame(maxHeight: .infinity)
            
            TryAgainButton()
            
            HStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
        }.frame(maxWidth: .infinity, alignment: .top)
        .toastView(toast: $toast)
    }
}
