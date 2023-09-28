//
//  BottomSheetView.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI
import UIKit

struct BottomSheetView: View {
    
    @ObservedObject var viewModel : BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject var adyenController: AdyenController = AdyenController.shared
    
    var body: some View {
        ZStack {
            
            Color.black.opacity(0.3).onTapGesture { if viewModel.purchaseState != .processing && !(viewModel.purchaseState == .adyen && adyenController.state == .none) { viewModel.dismiss() } }
                .ignoresSafeArea()
            
            ZStack {
                // Background
                VStack(spacing: 0) {
                    Color.clear
                        .frame(maxHeight: .infinity)
                    
                    if [.paying, .adyen].contains(viewModel.purchaseState) {
                        if adyenController.state != .storedCreditCard {
                            ColorsUi.APC_LightGray
                                .frame(height: Utils.bottomSafeAreaHeight)
                        }
                    } else {
                        ColorsUi.APC_DarkBlue
                            .frame(height: Utils.bottomSafeAreaHeight)
                    }
                }.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack{ }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    if [.paying, .adyen].contains(viewModel.purchaseState) {
                        PurchaseBottomSheet(viewModel: viewModel)
                    }
                    
                    if viewModel.purchaseState == .processing {
                        ProcessingBottomSheet(viewModel: viewModel)
                    }
                
                    if viewModel.purchaseState == .success {
                        SuccessBottomSheet(viewModel: viewModel)
                            .offset(y: viewModel.dismissingSuccess ? 0 : 348)
                            .transition(.move(edge: .top))
                            .animation(.easeOut(duration: 0.5).delay(2.5))
                    }
                    
                    if viewModel.purchaseState == .failed {
                        ErrorBottomSheet(viewModel: viewModel)
                    }
                    
                    if viewModel.purchaseState == .nointernet {
                        NoInternetBottomSheet(viewModel: viewModel)
                    }
                    
                }
                
                // Workaround to place multiple sheets on the same view on older iOS versions
                // https://stackoverflow.com/a/64403206/18917552
                HStack(spacing: 0) {}
                    .sheet(isPresented: $viewModel.presentPayPalSheet, onDismiss: viewModel.dismissPayPalView) {
                        if let presentURL = viewModel.presentPayPalSheetURL {
                            PayPalWebView(url: presentURL, method: viewModel.presentPayPalSheetMethod ?? "POST", successHandler: viewModel.createBillingAgreementAndFinishTransaction, cancelHandler: viewModel.cancelBillingAgreementTokenPayPal)
                        }
                    }
                
                HStack(spacing: 0) {}
                    .sheet(isPresented: $adyenController.presentAdyenRedirect) {
                        if let viewController = adyenController.presentableComponent?.viewController {
                            AdyenViewControllerWrapper(viewController: viewController)
                        }
                    }
            }
            .offset(y: viewModel.isBottomSheetPresented ? 0 : UIScreen.main.bounds.height)
            .transition(.move(edge: viewModel.isBottomSheetPresented ? .bottom : .top))
            .onAppear { withAnimation { viewModel.isBottomSheetPresented = true } }
//            .onDisappear { withAnimation { viewModel.isBottomSheetPresented = false } }
        }
    }
}

extension BottomSheetView {
    func toUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}
