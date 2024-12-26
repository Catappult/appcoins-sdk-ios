//
//  CreditCardBottomSheet.swift
//
//
//  Created by aptoide on 29/08/2023.
//

import Foundation
import SwiftUI
@_implementationOnly import ActivityIndicatorView

internal struct CreditCardFormBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var transactionViewModel: TransactionViewModel
    @ObservedObject internal var authViewModel: AuthViewModel
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    
    @Binding internal var dynamicHeight: CGFloat
    internal var startObservingDynamicHeight: () -> Void
    internal var stopObservingDynamicHeight: () -> Void
    
    internal var body: some View {
        
        VStack(spacing: 0) {
            
            if viewModel.orientation == .landscape {
                VStack(spacing: 0) {
                    HStack{}.frame(height: 72)
                    
                    if let viewController = adyenController.presentableComponent?.viewController {
                        ScrollView(showsIndicators: false) {
                            AdyenViewControllerWrapper(viewController: viewController, orientation: viewModel.orientation == .landscape ? .landscape : .portrait)
                                .frame(height: UIScreen.main.bounds.height * 0.9 - 72)
                        }.frame(width: UIScreen.main.bounds.width - 176 - 32, height: UIScreen.main.bounds.height * 0.9 - 72)
                    } else {
                        APPCLoading()
                    }
                }
            } else {
                VStack(spacing: 0) {
                    HStack{}.frame(height: 72)
                    
                    if let viewController = adyenController.presentableComponent?.viewController {
                        AdyenViewControllerWrapper(viewController: viewController, orientation: viewModel.orientation)
                            .frame(height: dynamicHeight)
                    } else {
                        APPCLoading()
                    }
                }.frame(width: UIScreen.main.bounds.width - 32)
            }
        }
        .onAppear{ startObservingDynamicHeight() }
        .onDisappear{ stopObservingDynamicHeight() }
    }
}
