//
//  ProviderBottomSheet.swift
//
//
//  Created by aptoide on 02/05/2025.
//

import Foundation
import SwiftUI
import UIKit
@_implementationOnly import WebKit

internal struct ProviderBottomSheet: View {
    
    @ObservedObject internal var viewModel: ProviderViewModel = ProviderViewModel.shared
    @Environment(\.colorScheme) var colorScheme
    
    internal var body: some View {
        HStack(spacing: 0) {}
            .sheet(isPresented: $viewModel.isChoosingProvider, onDismiss: viewModel.dismiss, content: {
                if #available(iOS 17.4, *) {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            HStack{}.frame(height: 8)
                            
                            Button(action: { ProviderViewModel.shared.chooseProvider(provider: .aptoide) }) {
                                ZStack {
                                    ColorsUi.APT_AptoideOrange
                                    
                                    HStack(spacing: 0) {
                                        Text("Pay with Trivial Drive")
                                            .foregroundStyle(Color.white)
                                        
                                        VStack{}.frame(width: 10)
                                        
                                        ZStack{
                                            ColorsUi.APT_AptoideBlue
                                            
                                            Text("-10%")
                                                .foregroundStyle(Color.white)
                                                .font(.footnote)
                                                .fontWeight(.bold)
                                        }.frame(width: 48, height: 24)
                                            .cornerRadius(12)
                                    }
                                    
                                }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 116 - 32: UIScreen.main.bounds.width - 32, height: 48)
                                    .cornerRadius(12)
                            }
                            
                            HStack{}.frame(height: 8)
                            
                            Button(action: { ProviderViewModel.shared.chooseProvider(provider: .apple) }) {
                                ZStack {
                                    Color.black
                                    
                                    Text("Pay with Apple")
                                        .foregroundStyle(Color.white)
                                }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 116 - 32: UIScreen.main.bounds.width - 32, height: 48)
                                    .cornerRadius(12)
                            }
                            
                            HStack{}.frame(height: 8)
                        }
                        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 116: UIScreen.main.bounds.width, alignment: .top)
                        .presentationCompactAdaptation(.sheet)
                        .presentationDetents([.height(Utils.bottomSafeAreaHeight + 120)])
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(self.colorScheme == .dark ? ColorsUi.APC_WebViewDarkMode : ColorsUi.APC_WebViewLightMode)
                }
            })
    }
}

internal extension ProviderBottomSheet {
    func toUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}
