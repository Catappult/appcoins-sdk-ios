//
//  AptoideProviderButton.swift
//  AppCoinsSDK
//
//  Created by aptoide on 02/06/2025.
//

import SwiftUI
@_implementationOnly import SkeletonUI

internal struct AptoideProviderButton: View {

    @ObservedObject internal var viewModel: ProviderViewModel = ProviderViewModel.shared

    internal var body: some View {
        ZStack {
            Button(action: { ProviderViewModel.shared.chooseProvider(provider: .aptoide) }) {
                ZStack {
                    ColorsUi.APC_AptoideGradient

                    HStack(spacing: 0) {
                        VStack{}.frame(maxWidth: .infinity)

                        VStack{}.frame(width: 16)

                        Text(String(format: Constants.payWith, BuildConfiguration.appName))
                            .foregroundColor(Color.white)
                            .font(FontsUi.APC_Body_Bold)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .layoutPriority(1)

                        HStack(spacing: 0){
                            VStack{}.frame(maxWidth: .infinity)

                            VStack{}.frame(width: 16)

                            if let rawAmount = viewModel.product?.priceValue, let amount = Double(rawAmount), let currency = viewModel.userCurrency {
                                Text(currency.sign + String(format: "%.2f", amount))
                                    .foregroundColor(Color.white)
                                    .font(FontsUi.APC_Callout_Bold)
                                    .fixedSize(horizontal: true , vertical: true)

                                VStack{}.frame(width: 8)

                                Text(currency.currency)
                                    .foregroundColor(Color.white)
                                    .font(FontsUi.APC_Footnote_Bold)
                                    .fixedSize(horizontal: true , vertical: true)
                            } else {
                                Text("")
                                    .skeleton(with: true)
                                    .frame(width: 48, height: 16)
                            }

                            VStack{}.frame(width: 24)

                        }.frame(maxWidth: .infinity)
                    }

                }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 116 - 32 : UIScreen.main.bounds.width - 32)
                 .frame(minHeight: 48)
                    .cornerRadius(12)
            }

            ZStack{
                ColorsUi.APC_AptoidePurple

                if let discount = viewModel.product?.priceDiscountPercentage {
                    Text("-\(discount)%")
                        .foregroundColor(Color.white)
                        .font(FontsUi.APC_Caption1_Bold)
                } else {
                    Text("")
                        .skeleton(with: true)
                        .frame(width: 32, height: 14)
                }
            }
            .frame(width: 44, height: 24)
            .cornerRadius(12)
            .offset(x: viewModel.orientation == .landscape ? (UIScreen.main.bounds.width - 116 - 60) / 2 : (UIScreen.main.bounds.width - 60) / 2, y: -20)
        }
    }
}
