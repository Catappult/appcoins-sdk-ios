//
//  LoginErrorExclamationImageAndLabel.swift
//
//
//  Created by aptoide on 02/01/2025.
//

import SwiftUI

internal struct LoginErrorExclamationImageAndLabel: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    internal var body: some View {
        VStack(spacing: 0) {
            Image("exclamation-red", bundle: Bundle.APPCModule)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .frame(width: 80, height: 80)
            
            HStack{}.frame(height: 16)
            
            Text(Constants.errorText)
                .font(FontsUi.APC_Title3_Bold)
                .foregroundColor(ColorsUi.APC_Black)
            
            HStack{}.frame(height: 16)
            
            Text(Constants.somethingWentWrong)
                .font(FontsUi.APC_Footnote)
                .foregroundColor(ColorsUi.APC_Black)
        }
    }
}
