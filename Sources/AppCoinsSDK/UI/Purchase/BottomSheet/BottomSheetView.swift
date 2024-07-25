//
//  BottomSheetView.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI
import UIKit

internal struct BottomSheetView: View {
    
    @ObservedObject var viewModel : BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject var adyenController: AdyenController = AdyenController.shared
    @ObservedObject var paypalViewModel : PayPalDirectViewModel = PayPalDirectViewModel.shared
    
    @State private var isSafeAreaPresented = false
    
    internal var body: some View {
        ZStack {
            
            Color.black.opacity(0.3).onTapGesture { viewModel.dismiss() }
                .ignoresSafeArea()
            
            ZStack {
                switch viewModel.purchaseState {
                case .initialAskForSync:
                    VStack(spacing: 0) {
                        Color.clear.frame(maxHeight: .infinity)
                        
                        InitialSyncBottomSheet(viewModel: viewModel)
                    }.ignoresSafeArea()
                    
                case .successAskForInstall:
                    VStack(spacing: 0) {
                        Color.clear.frame(maxHeight: .infinity)
                        
                        SuccessAskForInstallBottomSheet(viewModel: viewModel)
                    }.ignoresSafeArea()
                    
                
                case .successAskForSync:
                    VStack(spacing: 0) {
                        Color.clear.frame(maxHeight: .infinity)
                        
                        SuccessAskForSyncBottomSheet(viewModel: viewModel)
                    }.ignoresSafeArea()
                
                case .syncProcessing:
                    VStack(spacing: 0) {
                        Color.clear.frame(maxHeight: .infinity)
                        
                        SyncProcessingBottomSheet()
                    }.ignoresSafeArea()
                
                case .syncSuccess:
                    VStack(spacing: 0) {
                        Color.clear.frame(maxHeight: .infinity)
                        
                        SyncSuccessBottomSheet()
                    }.ignoresSafeArea()
                    
                case .syncError:
                    VStack(spacing: 0) {
                        Color.clear.frame(maxHeight: .infinity)
                        
                        SyncErrorBottomSheet()
                    }.ignoresSafeArea()
                    
                default:
                    EmptyView()
                }
                
                VStack(spacing: 0) {
                    VStack{ }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    if [.paying, .adyen].contains(viewModel.purchaseState) && !(viewModel.purchaseState == .adyen && adyenController.state == .storedCreditCard) {
                        PurchaseBottomSheet(viewModel: viewModel)
                    }
                    
                    if viewModel.purchaseState == .processing {
                        ProcessingBottomSheet(viewModel: viewModel)
                    }
                
                    if viewModel.purchaseState == .success {
                        SuccessBottomSheet(viewModel: viewModel)
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
                    .sheet(isPresented: $paypalViewModel.presentPayPalSheet, onDismiss: paypalViewModel.dismissPayPalView) {
                        if let presentURL = paypalViewModel.presentPayPalSheetURL {
                            PayPalWebView(url: presentURL, method: paypalViewModel.presentPayPalSheetMethod ?? "POST", successHandler: paypalViewModel.createBillingAgreementAndFinishTransaction, cancelHandler: paypalViewModel.cancelBillingAgreementTokenPayPal)
                        }
                    }
                
                HStack(spacing: 0) {}
                    .sheet(isPresented: $adyenController.presentAdyenRedirect) {
                        if let viewController = adyenController.presentableComponent?.viewController {
                            AdyenViewControllerWrapper(viewController: viewController)
                        }
                    }
                
                // Safe Area color
                VStack(spacing: 0) {
                    Color.clear
                        .frame(maxHeight: .infinity)
                    
                    if [.paying, .adyen].contains(viewModel.purchaseState) {
                        if adyenController.state != .storedCreditCard {
                            APPCColor.lightGray
                                .frame(height: Utils.bottomSafeAreaHeight)
                                .offset(y: isSafeAreaPresented ? 0 : UIScreen.main.bounds.height)
                                .transition(.move(edge: isSafeAreaPresented ? .bottom : .top))
                                .onAppear { withAnimation { isSafeAreaPresented = true } }
                        }
                    } else if ![.initialAskForSync, .successAskForInstall, .successAskForSync].contains(viewModel.purchaseState) {
                        APPCColor.darkBlue
                            .frame(height: Utils.bottomSafeAreaHeight)
                    }
                }.ignoresSafeArea()
            }
            .offset(y: viewModel.isBottomSheetPresented ? 0 : UIScreen.main.bounds.height)
            .transition(.move(edge: viewModel.isBottomSheetPresented ? .bottom : .top))
            .onAppear { withAnimation { viewModel.isBottomSheetPresented = true } }
        }
    }
}

internal extension BottomSheetView {
    func toUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}
