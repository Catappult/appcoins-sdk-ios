//
//  NoInternetBottomSheet.swift
//
//
//  Created by aptoide on 25/05/2023.
//

import SwiftUI

internal struct NoInternetBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    internal var body: some View {
        
        ZStack {
            ColorsUi.APC_BottomSheet_LightGray_Background
            VStack(spacing: 0) {
                DismissHeader()
                
                VStack{}.frame(maxHeight: .infinity)
                
                NoInternetIconAndLabel()
                
                VStack{}.frame(maxHeight: .infinity)
                
                NoInternetReloadButton()
                
                VStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
                
            }
        }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width, height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : 420)
            .cornerRadius(13, corners: [.topLeft, .topRight])
    }
}
