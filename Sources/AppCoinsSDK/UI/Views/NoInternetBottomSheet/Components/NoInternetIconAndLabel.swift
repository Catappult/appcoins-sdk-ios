//
//  NoInternetIconAndLabel.swift
//
//
//  Created by aptoide on 02/01/2025.
//

import SwiftUI

internal struct NoInternetIconAndLabel: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    internal var body: some View {
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
    }
}