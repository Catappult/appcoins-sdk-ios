//
//  PurchasePrice.swift
//  AppCoinsSDK
//
//  Created by aptoide on 30/05/2025.
//

import SwiftUI

internal struct PurchasePrice: View {
    
    @ObservedObject internal var viewModel: ProviderViewModel = ProviderViewModel.shared
    @Environment(\.colorScheme) var colorScheme
    
    internal var body: some View {
        HStack(spacing: 0) {
            if let originalPriceRaw = viewModel.product?.priceDiscountOriginal, let originalPrice = Double(originalPriceRaw), let currency = viewModel.userCurrency {
                Text(currency.sign + String(format: "%.2f", originalPrice))
                    .foregroundColor(self.colorScheme == .dark ? ColorsUi.APC_White :  ColorsUi.APC_Black)
                    .font(FontsUi.APC_Subheadline_Bold)
                    .lineLimit(1)
                
                VStack{}.frame(width: 4)
                
                Text(currency.currency)
                    .foregroundColor(self.colorScheme == .dark ? ColorsUi.APC_White :  ColorsUi.APC_Black)
                    .font(FontsUi.APC_Caption1_Bold)
                    .lineLimit(1)
            } else {
                HStack(spacing: 0) {
                    Text("")
                        .skeleton(with: true)
                        .frame(width: 60, height: 14, alignment: .leading)
                    VStack{}.frame(maxWidth: .infinity)
                }.frame(maxWidth: .infinity)
            }
        }
        .frame(width: viewModel.orientation == .landscape ? 256 : UIScreen.main.bounds.width - 154, alignment: .bottomLeading)
    }
}
