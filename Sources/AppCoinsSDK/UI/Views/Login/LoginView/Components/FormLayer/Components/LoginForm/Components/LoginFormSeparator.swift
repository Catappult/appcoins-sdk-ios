//
//  LoginFormSeparator.swift
//  
//
//  Created by aptoide on 30/12/2024.
//

import SwiftUI

internal struct LoginFormSeparator: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    internal var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(width: viewModel.orientation == .landscape ? 222 : 106, height: 1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(ColorsUi.APC_DarkGray)
            
            Text(Constants.orContinueWith)
                .font(FontsUi.APC_Caption1)
                .foregroundColor(ColorsUi.APC_DarkGray)
            
            Rectangle()
                .frame(width: viewModel.orientation == .landscape ? 222 : 106, height: 1)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(ColorsUi.APC_DarkGray)
        }.frame(height: 16)
    }
}
