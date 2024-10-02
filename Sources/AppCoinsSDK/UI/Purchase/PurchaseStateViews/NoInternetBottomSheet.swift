//
//  NoInternetBottomSheet.swift
//
//
//  Created by aptoide on 25/05/2023.
//

import Foundation
import SwiftUI
import URLImage

internal struct NoInternetBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    
    internal var body: some View {
        
        ZStack {
            ColorsUi.APC_DarkBlue
            VStack(spacing: 0) {
                VStack {}.frame(height: 16)
                
                HStack(spacing: 0) {
                    Button {
                        viewModel.dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(ColorsUi.APC_BackgroundDarkGray_Button)
                                .frame(width: 30, height: 30)
                            
                            Image(systemName: "xmark")
                                .foregroundColor(ColorsUi.APC_LightGray_Xmark)
                            
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                    
                    VStack {}.frame(width: 24)
                    
                }
                
                VStack {}.frame(height: viewModel.isLandscape ? 21 : 61)
                
                Image("no-internet-white", bundle: Bundle.module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                
                VStack {}.frame(height: 16)
                
                Text(Constants.noInternetTitle)
                    .font(FontsUi.APC_Title3_Bold)
                    .foregroundColor(ColorsUi.APC_White)
                
                VStack {}.frame(height: 15)
                
                Text(Constants.noInternetText)
                    .font(FontsUi.APC_Footnote)
                    .foregroundColor(ColorsUi.APC_White)
                    .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 376 : UIScreen.main.bounds.width - 48)
                    .multilineTextAlignment(.center)
                
                VStack {}.frame(height: viewModel.isLandscape ? 21 : 61)
                
                Button(action: {viewModel.reload()}) {
                    ZStack {
                        ColorsUi.APC_Pink
                        
                        Text(Constants.retryConnection)
                            .font(FontsUi.APC_Body_Bold)
                            .foregroundColor(ColorsUi.APC_White)
                    }
                    .cornerRadius(10)
                }.frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 320 : UIScreen.main.bounds.width - 48, height: 50, alignment: .bottom)
                
                VStack {}.frame(height: 47)
                
            }
        }.frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width, height: viewModel.isLandscape ? UIScreen.main.bounds.height * 0.9 : 436)
            .cornerRadius(13, corners: [.topLeft, .topRight])
    }
}
