//
//  NoInternetReloadButton.swift
//
//
//  Created by aptoide on 02/01/2025.
//

import SwiftUI

internal struct NoInternetReloadButton: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    internal var body: some View {
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
    }
}
