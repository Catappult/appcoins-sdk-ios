//
//  SDKBottomSheet.swift
//  AppCoinsSDK
//
//  Created by aptoide on 03/06/2025.
//

import SwiftUI

internal struct SDKBottomSheet<Content: View>: View {
    
    @ObservedObject internal var viewModel: ProviderViewModel = ProviderViewModel.shared
    @Environment(\.colorScheme) internal var colorScheme
    internal let content: Content
    internal let dismiss: () -> Void
    internal let background: Color
    internal let width: CGFloat
    internal let height: CGFloat

    
    internal init(@ViewBuilder content: () -> Content, dismiss: @escaping () -> Void, background: Color, width: CGFloat, height: CGFloat) {
        self.content = content()
        self.dismiss = dismiss
        self.background = background
        self.width = width
        self.height = height
    }

    internal var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { dismiss() }
            
            VStack(spacing: 0) {
                Spacer()
                
                HStack(spacing: 0) {
                    Spacer()
                    
                    ZStack {
                        background
                        content
                    }
                    .frame(width: width, height: height, alignment: .bottom)
                    .cornerRadius(12, corners: [.topLeft, .topRight])
                    .onTapGesture { }
                    
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
