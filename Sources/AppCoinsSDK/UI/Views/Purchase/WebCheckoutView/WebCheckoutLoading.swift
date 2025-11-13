//
//  WebCheckoutLoading.swift
//  AppCoinsSDK
//
//  Created by aptoide on 03/06/2025.
//

import SwiftUI

@available(iOS 14, *)
internal struct WebCheckoutLoading: View {
    
    @ObservedObject internal var viewModel: PurchaseViewModel = PurchaseViewModel.shared
    @Environment(\.colorScheme) var colorScheme
    
    internal var body: some View {
        ZStack {
            Color.black.opacity(0.7)
            
            ZStack {
                VStack {
                    if #available(iOS 15, *) {
                        ProgressView().tint(.white)
                    } else {
                        LegacyProgressView()
                    }
                }
                .frame(maxHeight: .infinity)
                
                VStack {
                    HStack{}.frame(maxHeight: .infinity)
    
                    Button { viewModel.dismiss() } label: {
                        Text(Constants.cancelButton)
                            .frame(maxWidth: .infinity)
                    }
                    
                    HStack{}.frame(height: Utils.bottomSafeAreaHeight + 8)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
