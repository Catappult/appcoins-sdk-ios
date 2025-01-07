//
//  LoginNoInternetImageAndLabel.swift
//  
//
//  Created by aptoide on 06/01/2025.
//

import SwiftUI

internal struct LoginNoInternetImageAndLabel: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    internal var body: some View {
        VStack(spacing: 0) {
            Image("no-internet-black", bundle: Bundle.APPCModule)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .frame(width: 80, height: 80)
            
            HStack{}.frame(height: 16)
            
            Text(Constants.noInternetTitle)
                .font(FontsUi.APC_Title3_Bold)
                .foregroundColor(ColorsUi.APC_Black)
            
            HStack{}.frame(height: 16)
            
            Text(Constants.noInternetText)
                .font(FontsUi.APC_Footnote)
                .foregroundColor(ColorsUi.APC_Black)
        }
    }
}
