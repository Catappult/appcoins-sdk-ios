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
            Button {
                viewModel.dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5)))
                        .frame(width: 30, height: 30)
                    Image(systemName: "xmark")
                        .foregroundColor(Color(UIColor(red: 0.24, green: 0.24, blue: 0.24, alpha: 1)))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            
            
            if let viewController = adyenController.presentableComponent?.viewController {
                AdyenViewControllerWrapper(viewController: viewController)
                    .frame(height: dynamicHeight)
            } else {
                ZStack {
                    ActivityIndicatorView(
                        isVisible: .constant(true), type: .growingArc(ColorsUi.APC_Gray, lineWidth: 1.5))
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
