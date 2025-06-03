//
//  AppleProviderButton.swift
//  AppCoinsSDK
//
//  Created by aptoide on 02/06/2025.
//

import SwiftUI

internal struct AppleProviderButton: View {
    
    @ObservedObject internal var viewModel: ProviderViewModel = ProviderViewModel.shared
    
    internal var body: some View {
        Button(action: { ProviderViewModel.shared.chooseProvider(provider: .apple) }) {
            ZStack {
                Color.black
                
                HStack(spacing: 0) {
                    Text("Pay with")
                        .foregroundColor(Color.white)
                        .font(FontsUi.APC_Body_Bold)
                    
                    HStack{}.frame(width: 6)
                    
                    Image("apple-pay", bundle: Bundle.APPCModule)
                        .resizable()
                        .frame(width: 48, height: 20)
                }
                
            }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 116 - 32: UIScreen.main.bounds.width - 32, height: 48)
                .cornerRadius(12)
        }
    }
}
