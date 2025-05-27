//
//  DeleteAccountLabel.swift
//
//
//  Created by aptoide on 03/01/2025.
//

import SwiftUI

internal struct DeleteAccountLabel: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var deleteSentCodeLabelHeight: CGFloat {
        String(format: Constants.sentEmailTo, authViewModel.deleteAccountEmail)
            .height(
                withConstrainedWidth: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48,
                font: UIFont.systemFont(ofSize: 15, weight: .regular)
            )
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
            Text(Constants.checkYourEmail)
                .font(FontsUi.APC_Title3_Bold)
                .foregroundColor(ColorsUi.APC_Black)
            
            VStack{}.frame(height: 8)
            
            Text(String(format: Constants.sentEmailTo, authViewModel.deleteAccountEmail))
                .font(FontsUi.APC_Subheadline)
                .foregroundColor(ColorsUi.APC_Black)
                .frame(
                    width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48,
                    height: deleteSentCodeLabelHeight,
                    alignment: .top
                )
                .multilineTextAlignment(.center)
        }
    }
}
