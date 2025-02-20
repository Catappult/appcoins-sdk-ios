//
//  MagicLinkCounter.swift
//
//
//  Created by aptoide on 03/01/2025.
//

import SwiftUI

internal struct MagicLinkCounter: View {
    
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var body: some View {
        Text(formattedTime(from: authViewModel.retryMagicLinkIn))
            .font(FontsUi.APC_Title1_Bold)
            .foregroundColor(ColorsUi.APC_DarkGray_Xmark)
            .frame(height: 24)
    }
    
    private func formattedTime(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
