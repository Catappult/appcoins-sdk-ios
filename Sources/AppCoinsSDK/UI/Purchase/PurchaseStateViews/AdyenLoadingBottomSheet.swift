//
//  AdyenLoadingBottomSheet.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import SwiftUI
@_implementationOnly import ActivityIndicatorView

internal struct AdyenLoadingBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    
    internal var body: some View {
        
        VStack(spacing: 0) {
            ZStack {
                ActivityIndicatorView(
                    isVisible: .constant(true), type: .growingArc(ColorsUi.APC_Gray, lineWidth: 1.5))
                .frame(width: 41, height: 41)
                
                Image("loading-appc-icon", bundle: Bundle.APPCModule)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 23)
            }.animation(.linear(duration: 1.5).repeatForever(autoreverses: false))
        }.padding(.horizontal, 16)
        
    }
}
