//
//  TryAgainButton.swift
//
//
//  Created by aptoide on 02/01/2025.
//

import SwiftUI

internal struct TryAgainButton: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var body: some View {
        Button(action: authViewModel.tryAgain ) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(ColorsUi.APC_Pink)
                
                Text(Constants.tryAgain)
                    .font(FontsUi.APC_Body_Bold)
                    .foregroundColor(ColorsUi.APC_White)
            }
        }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
    }
}
