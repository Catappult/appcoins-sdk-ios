//
//  NoInternetBottomSheet.swift
//
//
//  Created by aptoide on 25/05/2023.
//

import Foundation
import SwiftUI

internal struct NoInternetBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    
    internal var body: some View {
        
        ZStack {
            ColorsUi.APC_BottomSheet_LightGray_Background
            VStack(spacing: 0) {
                
                VStack{}.frame(height: 16)
                
                HStack(spacing: 0) {
                    CloseButton(action: viewModel.dismiss)
                        .frame(maxWidth: .infinity, alignment: .topTrailing)
                    
                    VStack{}.frame(width: 24)
                }
                
                VStack{}.frame(height:viewModel.orientation == .landscape ? 21 : 61)
                
                Image("no-internet-black", bundle: Bundle.APPCModule)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(ColorsUi.APC_Black)
                    .frame(width: 80, height: 80)
                
                VStack{}.frame(height: 16)
                
                Text(Constants.noInternetTitle)
                    .font(FontsUi.APC_Title3_Bold)
                    .foregroundColor(ColorsUi.APC_Black)
                
                VStack{}.frame(height: 15)
                
                Text(Constants.noInternetText)
                    .lineLimit(2)
                    .font(FontsUi.APC_Footnote)
                    .foregroundColor(ColorsUi.APC_Black)
                    .multilineTextAlignment(.center)
                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 376 : UIScreen.main.bounds.width - 48, height: 40)
                
                VStack{}.frame(height: viewModel.orientation == .landscape ? 21 : 40)
                
                Button(action: {viewModel.reload()}) {
                    ZStack {
                        ColorsUi.APC_Pink
                        
                        Text(Constants.retryConnection)
                            .font(FontsUi.APC_Body_Bold)
                            .foregroundColor(ColorsUi.APC_White)
                    }
                    .cornerRadius(10)
                }
                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                .frame(maxHeight: .infinity, alignment: .bottom)
                
                VStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
                
            }
        }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width, height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : 420)
            .cornerRadius(13, corners: [.topLeft, .topRight])
    }
}
