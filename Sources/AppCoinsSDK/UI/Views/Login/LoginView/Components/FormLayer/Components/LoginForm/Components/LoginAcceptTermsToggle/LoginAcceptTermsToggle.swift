//
//  LoginAcceptTermsToggle.swift
//
//
//  Created by aptoide on 08/01/2025.
//

import SwiftUI

internal struct LoginAcceptTermsToggle: View {
    
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var body: some View {
        if #available(iOS 16.0, *) {
            HStack(spacing: 0) {
                LoginAcceptTermsToggleLabel()
                    .font(FontsUi.APC_Caption1)
                
                Toggle(isOn: $authViewModel.hasAcceptedTC) {}
                    .tint(ColorsUi.APC_Pink)
                    .toggleStyle(SwitchToggleStyle())
                    .scaleEffect(0.6)
                    .frame(width: 40, height: 20)
            }
        }
    }
}
