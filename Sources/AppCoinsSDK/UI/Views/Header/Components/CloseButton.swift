//
//  CloseButton.swift
//
//
//  Created by aptoide on 24/12/2024.
//

import SwiftUI

internal struct CloseButton: View {
    internal let action: () -> Void

    internal init(action: @escaping () -> Void) {
        self.action = action
    }
    
    internal var body: some View {
        Button(action: action) {
            Circle()
                .fill(ColorsUi.APC_BackgroundLightGray_Button)
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: "xmark")
                        .foregroundColor(ColorsUi.APC_DarkGray_Xmark)
                )
        }
    }
}
