//
//  SelectPaymentMethodButton.swift
//
//
//  Created by aptoide on 26/12/2024.
//

import SwiftUI

internal struct SelectPaymentMethodButton: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    internal let textHeight: CGFloat
    internal let fontSize: UIFont
    
    init() {
        self.fontSize = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        if Constants.selectPaymentMethodText.exactWidth(using: self.fontSize) < 280 {
            self.textHeight = self.fontSize.lineHeight
        } else {
            self.textHeight = Constants.sentEmailTo.minimumHeightNeeded(withConstrainedWidth: 280, font: self.fontSize, maxLines: 2)
        }
    }
    
    internal var body: some View {
        Button {
            viewModel.presentPaymentMethodChoiceSheet()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text(Constants.selectPaymentMethodText)
                        .font(FontsUi.APC_Body)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    HStack{}.frame(width: 8)
                    
                    Image(systemName: "chevron.right")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .frame(width: 7, height: 12)
                        .foregroundColor(ColorsUi.APC_SelectionArrow)
                }
                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 32 - 48 : UIScreen.main.bounds.width - 32 - 48, height: textHeight)
            }
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: viewModel.orientation == .landscape ? 40 : 20 + textHeight)
            .background(ColorsUi.APC_White)
            .cornerRadius(10)
        }
        .buttonStyle(flatButtonStyle())
    }
}
