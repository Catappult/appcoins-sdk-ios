//
//  DeleteAccountFailedView.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/05/2025.
//

import SwiftUI

internal struct DeleteAccountFailedView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @State private var toast: FancyToast? = nil
    
    internal var body: some View {
        VStack(spacing: 0) {
            HStack{}.frame(maxHeight: .infinity)
            
            DeleteAccountErrorExclamationImageAndLabel()
            
            HStack{}.frame(maxHeight: .infinity)
            
            DeleteAccountTryAgainButton()
            
            HStack{}.frame(height: 19)
            
            DeleteAccountErrorSupportButton(toast: $toast)
            
            HStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
        }.frame(maxWidth: .infinity, alignment: .top)
        .toastView(toast: $toast)
    }
}
