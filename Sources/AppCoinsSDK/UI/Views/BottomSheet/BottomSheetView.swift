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
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    @ObservedObject internal var paypalViewModel: PayPalDirectViewModel = PayPalDirectViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    @State private var isSafeAreaPresented = false
    
    internal var body: some View {
        ZStack {
            
            Color.black.opacity(0.3)
                .onTapGesture {
                    if viewModel.isKeyboardVisible {
                        AdyenController.shared.presentableComponent?.viewController.view.findAndResignFirstResponder()
                        UIApplication.shared.dismissKeyboard()
                    } else {
                        viewModel.dismiss()
                    }
                }
                .ignoresSafeArea()
            
            ZStack {
                VStack(spacing: 0) {
                    VStack{ }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    if [.loading, .paying, .adyen, .login].contains(viewModel.purchaseState) && !(viewModel.purchaseState == .adyen && adyenController.state == .storedCreditCard) {
                        PurchaseBottomSheet()
                    }
                    
                    if viewModel.purchaseState == .processing {
                        ProcessingBottomSheet()
                    }
                    
                    if viewModel.purchaseState == .success {
                        SuccessBottomSheet()
                    }
                    
                    if viewModel.purchaseState == .failed {
                        ErrorBottomSheet()
                    }
                    
                    if viewModel.purchaseState == .nointernet {
                        NoInternetBottomSheet()
                    }
                }
                
                // Workaround to place multiple sheets on the same view on older iOS versions
                // https://stackoverflow.com/a/64403206/18917552
                HStack(spacing: 0) {}
                    .sheet(isPresented: $paypalViewModel.isPayPalSheetPresented, onDismiss: paypalViewModel.dismissPayPalView) {
                        if let presentURL = paypalViewModel.presentPayPalSheetURL {
                            PayPalWebView(url: presentURL, method: paypalViewModel.presentPayPalSheetMethod ?? "POST", successHandler: paypalViewModel.createBillingAgreementAndFinishTransaction, cancelHandler: paypalViewModel.cancelBillingAgreementTokenPayPal)
                        }
                    }
                
                HStack(spacing: 0) {}
                    .sheet(isPresented: $adyenController.isAdyenRedirectPresented) {
                        if let viewController = adyenController.presentableComponent?.viewController {
                            AdyenViewControllerWrapper(viewController: viewController, orientation: viewModel.orientation)
                                .ignoresSafeArea(.all)
                        }
                    }
                
                HStack(spacing: 0) {}
                    .sheet(isPresented: $viewModel.isPaymentMethodChoiceSheetPresented) {
                        PaymentMethodListBottomSheet(viewModel: viewModel)
                    }
            }
            .ignoresSafeArea(.all)
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
