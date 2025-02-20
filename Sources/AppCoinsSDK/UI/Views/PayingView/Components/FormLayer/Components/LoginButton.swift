//
//  LoginButton.swift
//
//
//  Created by aptoide on 26/12/2024.
//

import SwiftUI

internal struct LoginButton: View {
    
    internal var action: () -> Void
    internal var orientation: Orientation
    
    internal init(action: @escaping () -> Void, orientation: Orientation) {
        self.action = action
        self.orientation = orientation
    }
    
    internal var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text(Constants.signToGetBonusText)
                        .font(FontsUi.APC_Body)
                        .frame(width: 200, alignment: .leading)
                    
                    Image(systemName: "chevron.right")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .frame(height: 40)
                        .foregroundColor(ColorsUi.APC_SelectionArrow)
                    
                }
                .frame(width: orientation == .landscape ? UIScreen.main.bounds.width - 176 - 32 - 48 : UIScreen.main.bounds.width - 32 - 48, height: 40)
            }
            .frame(width: orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 40)
            .background(ColorsUi.APC_White)
            .cornerRadius(10)
        }.buttonStyle(flatButtonStyle())
    }
}
