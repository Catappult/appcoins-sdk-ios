//
//  LoginEmailConsentsToggle.swift
//
//
//  Created by aptoide on 08/01/2025.
//

import SwiftUI

internal struct LoginEmailConsentsToggle: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var body: some View {
        if #available(iOS 16.0, *) {
            HStack(spacing: 0) {
                Text(Constants.consentEmailBody)
                    .font(FontsUi.APC_Caption1)
                    .frame(
                        width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 40 : UIScreen.main.bounds.width - 48 - 40,
                        height: Constants.consentEmailBody
                            .height(
                                withConstrainedWidth: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 40 : UIScreen.main.bounds.width - 48 - 40,
                                font: UIFont.systemFont(ofSize: 12, weight: .regular)
                            ),
                        alignment: .trailing
                    )
                    .multilineTextAlignment(.trailing)
                
                Toggle(isOn: $authViewModel.hasConsentedEmailStorage) {}
                    .tint(ColorsUi.APC_Pink)
                    .toggleStyle(SwitchToggleStyle())
                    .scaleEffect(0.6)
                    .frame(width: 40, height: 20)
            }.frame(height: Constants.consentEmailBody
                .height(
                    withConstrainedWidth: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 40 : UIScreen.main.bounds.width - 48 - 40,
                    font: UIFont.systemFont(ofSize: 12, weight: .regular)
                )
            )
        }
    }
}
