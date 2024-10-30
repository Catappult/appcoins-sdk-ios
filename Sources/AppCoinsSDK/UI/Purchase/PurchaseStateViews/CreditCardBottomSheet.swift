//
//  CreditCardBottomSheet.swift
//
//
//  Created by aptoide on 29/08/2023.
//

import Foundation
import SwiftUI
@_implementationOnly import ActivityIndicatorView

internal struct CreditCardBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var transactionViewModel: TransactionViewModel
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    @Binding var dynamicHeight: CGFloat
    
    internal var body: some View {
        
        VStack(spacing: 0) {
            
            if viewModel.orientation == .landscape {
                VStack(spacing: 0) {
                    BottomSheetAppHeader(viewModel: viewModel, transactionViewModel: transactionViewModel)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .onTapGesture {
                            if viewModel.isKeyboardVisible {
                                AdyenController.shared.presentableComponent?.viewController.view.findAndResignFirstResponder()
                            }
                        }
                    
                    if let viewController = adyenController.presentableComponent?.viewController {
                        ScrollView(showsIndicators: false) {
                            AdyenViewControllerWrapper(viewController: viewController, orientation: viewModel.orientation == .landscape ? .landscape : .portrait)
                                .frame(height: UIScreen.main.bounds.height * 0.9 - 72)
                        }.frame(width: UIScreen.main.bounds.width - 176 - 32, height: UIScreen.main.bounds.height * 0.9 - 72)
                    } else {
                        ZStack {
                            ActivityIndicatorView(
                                isVisible: .constant(true), type: .growingArc(ColorsUi.APC_Gray, lineWidth: 1.5))
                            .frame(width: 41, height: 41)
                            
                            Image("loading-appc-icon", bundle: Bundle.APPCModule)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 23)
                        }.animation(.linear(duration: 1.5).repeatForever(autoreverses: false))
                    }
                }
            } else {
                VStack(spacing: 0) {
                    BottomSheetAppHeader(viewModel: viewModel, transactionViewModel: transactionViewModel)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .onTapGesture {
                            if viewModel.isKeyboardVisible {
                                AdyenController.shared.presentableComponent?.viewController.view.findAndResignFirstResponder()
                            }
                        }
                    
                    if let viewController = adyenController.presentableComponent?.viewController {
                        
                        AdyenViewControllerWrapper(viewController: viewController, orientation: viewModel.orientation)
                            .frame(height: dynamicHeight)
                    } else {
                        ZStack {
                            ActivityIndicatorView(
                                isVisible: .constant(true), type: .growingArc(ColorsUi.APC_Gray, lineWidth: 1.5))
                            .frame(width: 41, height: 41)
                            
                            Image("loading-appc-icon", bundle: Bundle.APPCModule)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 23)
                        }.animation(.linear(duration: 1.5).repeatForever(autoreverses: false))
                    }
                }.frame(width: UIScreen.main.bounds.width - 32)
            }
        }
    }
}
