//
//  CreditCardBottomSheet.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import Foundation
import SwiftUI
import ActivityIndicatorView

internal struct CreditCardBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    
    @Binding internal var dynamicHeight: CGFloat
    
    internal var body: some View {
       
        VStack(spacing: 0) {
            if let viewController = adyenController.presentableComponent?.viewController {
                
                AdyenViewControllerWrapper(viewController: viewController)
                    .padding(.top, 16)
                    .frame(height: dynamicHeight)
                    
                Button(action: {
                    adyenController.cancel()
                }) {
                    Text(Constants.cancelText)
                        .foregroundColor(APPCColor.darkGray)
                        .font(FontsUi.APC_Footnote_Bold)
                        .lineLimit(1)
                }.padding(.top, 4)
                
            } else {
                ZStack {
                    ActivityIndicatorView(
                        isVisible: .constant(true), type: .growingArc(APPCColor.gray, lineWidth: 1.5))
                        .frame(width: 41, height: 41)
                    
                    Image("loading-appc-icon", bundle: Bundle.module)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 23)
                }.animation(.linear(duration: 1.5).repeatForever(autoreverses: false))
            }
        }.padding(.horizontal, 16)
    }
}
