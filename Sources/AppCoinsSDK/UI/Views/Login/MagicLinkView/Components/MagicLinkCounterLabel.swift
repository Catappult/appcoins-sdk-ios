//
//  MagicLinkCounterLabel.swift
//
//
//  Created by aptoide on 03/01/2025.
//

import SwiftUI

internal struct MagicLinkCounterLabel: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    internal var magicLinkCounterLabelHeight: CGFloat
    
    internal var body: some View {
        Text(String(format: Constants.resendInTime, "30"))
            .font(FontsUi.APC_Subheadline)
            .foregroundColor(ColorsUi.APC_Black)
            .frame(
                width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48,
                height: magicLinkCounterLabelHeight,
                alignment: .top
            )
            .multilineTextAlignment(.center)
    }
}
