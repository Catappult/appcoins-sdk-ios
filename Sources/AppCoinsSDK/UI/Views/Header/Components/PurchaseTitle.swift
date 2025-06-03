//
//  PurchaseTitle.swift
//  AppCoinsSDK
//
//  Created by aptoide on 30/05/2025.
//

import SwiftUI
@_implementationOnly import SkeletonUI

internal struct PurchaseTitle: View {
    
    @ObservedObject internal var viewModel: ProviderViewModel = ProviderViewModel.shared
    @Environment(\.colorScheme) var colorScheme
    
    internal var body: some View {
        HStack(spacing: 0) {
            if let title = viewModel.product?.title {
                Text(title)
                    .foregroundColor(self.colorScheme == .dark ? ColorsUi.APC_White :  ColorsUi.APC_Black)
                    .font(FontsUi.APC_Body_Bold)
                    .lineLimit(1)
            } else {
                Text("")
                    .skeleton(with: true)
                    .frame(width: 125, height: 22, alignment: .leading)
                VStack{}.frame(maxWidth: .infinity)
            }
            
            VStack{}.frame(width: 16)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
