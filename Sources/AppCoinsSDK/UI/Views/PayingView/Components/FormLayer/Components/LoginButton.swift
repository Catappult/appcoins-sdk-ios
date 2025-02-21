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
    internal let textHeight: CGFloat
    
    internal init(action: @escaping () -> Void, orientation: Orientation) {
        self.action = action
        self.orientation = orientation
        self.textHeight = Constants.signToGetBonusText.minimumHeightNeeded(withConstrainedWidth: 250, font: UIFont.systemFont(ofSize: 17, weight: .regular), maxLines: 2)
    }
    
    internal var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text(Constants.signToGetBonusText)
                        .font(FontsUi.APC_Body)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    
                    HStack{}.frame(width: 8)
                    
                    Image(systemName: "chevron.right")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .frame(width: 7, height: 12)
                        .foregroundColor(ColorsUi.APC_SelectionArrow)
                    
                }
                .frame(width: orientation == .landscape ? UIScreen.main.bounds.width - 176 - 32 - 48 : UIScreen.main.bounds.width - 32 - 48, height: textHeight)
            }
            .frame(width: orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 20 + textHeight)
            .background(ColorsUi.APC_White)
            .cornerRadius(10)
        }.buttonStyle(flatButtonStyle())
    }
}
