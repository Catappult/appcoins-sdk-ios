//
//  SelectPaymentMethodButton.swift
//
//
//  Created by aptoide on 26/12/2024.
//

import SwiftUI

internal struct SelectPaymentMethodButton: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    internal var body: some View {
        Button {
            viewModel.presentPaymentMethodChoiceSheet()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text(Constants.selectPaymentMethodText)
                        .font(FontsUi.APC_Body)
                        .frame(width: 183, alignment: .leading)
                    
                    Image(systemName: "chevron.right")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .frame(height: 40)
                        .foregroundColor(ColorsUi.APC_SelectionArrow)
                }
                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 32 - 48 : UIScreen.main.bounds.width - 32 - 48, height: 40)
            }
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 40)
            .background(ColorsUi.APC_White)
            .cornerRadius(10)
        }
        .buttonStyle(flatButtonStyle())
    }
}
