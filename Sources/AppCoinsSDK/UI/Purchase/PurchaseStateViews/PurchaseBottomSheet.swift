//
//  PurchaseBottomSheet.swift
//
//
//  Created by aptoide on 31/08/2023.
//

import Foundation
import SwiftUI
@_implementationOnly import SkeletonUI
@_implementationOnly import ActivityIndicatorView

internal struct PurchaseBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    
    @State private var isPresented = false
    @ObservedObject private var keyboardObserver = KeyboardObserver.shared
    
    @State private var timer: Timer? = nil
    @State private var dynamicHeight: CGFloat = 291
    
    internal let portraitBottomSheetHeight: CGFloat = 420
    internal let buttonHeightPlusTopSpace: CGFloat = 58
    internal let bottomSheetHeaderHeight: CGFloat = 72
    internal let buttonBottomSafeArea: CGFloat = Utils.bottomSafeAreaHeight == 0 ? 5 : 28
    
    internal var body: some View {
        
        VStack(spacing: 0) {
            if viewModel.purchaseState == .paying {
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        if transactionViewModel.showOtherPaymentMethods || transactionViewModel.lastPaymentMethod != nil {
                            PurchaseView(viewModel: viewModel, portraitBottomSheetHeight: self.portraitBottomSheetHeight, buttonHeightPlusTopSpace: self.buttonHeightPlusTopSpace, bottomSheetHeaderHeight: self.bottomSheetHeaderHeight, buttonBottomSafeArea: buttonBottomSafeArea)
                        } else {
                            VStack(spacing: 0) {
                                
                                VStack{}.frame(height: 72)
                                
                                ZStack {
                                    ActivityIndicatorView(
                                        isVisible: .constant(true), type: .growingArc(ColorsUi.APC_Gray, lineWidth: 1.5))
                                    .frame(width: 41, height: 41)
                                    
                                    Image("loading-appc-icon", bundle: Bundle.APPCModule)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 23)
                                }
                            }.frame(maxHeight: .infinity, alignment: .center)
                        }
                        
                        VStack{}.frame(height: 8)
                        
                        // Buying button
                        Button(action: {
                            DispatchQueue.main.async { viewModel.purchaseState = .processing }
                            viewModel.buy()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(transactionViewModel.transaction != nil ? ColorsUi.APC_Pink : ColorsUi.APC_Gray)
                                Text(Constants.buyText)
                            }
                        }
                        .disabled(transactionViewModel.transaction == nil)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                        .foregroundColor(ColorsUi.APC_White)
                        
                        VStack{}.frame(height: buttonBottomSafeArea)
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    
                    BottomSheetAppHeader(viewModel: viewModel, transactionViewModel: transactionViewModel)
                }
            }
            
            if viewModel.purchaseState == .adyen {
                if adyenController.state == .none {
                    AdyenLoadingBottomSheet(viewModel: viewModel)
                }
                
                if adyenController.state == .choosingCreditCard {
                    CreditCardChoiceBottomSheet(viewModel: viewModel)
                }
                
                if adyenController.state == .newCreditCard {
                    CreditCardBottomSheet(viewModel: viewModel, transactionViewModel: transactionViewModel, authViewModel: authViewModel, dynamicHeight: $dynamicHeight)
                        .onAppear{
                            viewModel.setCreditCardView(isCreditCardView: true)
                            startObservingDynamicHeight()
                        }
                        .onDisappear{
                            if viewModel.isCreditCardView {
                                viewModel.setCreditCardView(isCreditCardView: false)
                            }
                            stopObservingDynamicHeight()
                        }
                }
                
                if adyenController.state == .paypal {
                    EmptyView()
                }
            }
            
            if viewModel.purchaseState == .login {
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        switch authViewModel.authState {
                        case .choice:
                            LoginView(viewModel: viewModel, authViewModel: authViewModel, transactionViewModel: transactionViewModel, portraitBottomSheetHeight: self.portraitBottomSheetHeight, buttonHeightPlusTopSpace: self.buttonHeightPlusTopSpace, bottomSheetHeaderHeight: self.bottomSheetHeaderHeight, buttonBottomSafeArea: buttonBottomSafeArea)
                        case .google:
                            EmptyView()
                        case .magicLink:
                            MagicLinkCodeView(viewModel: viewModel, authViewModel: authViewModel, transactionViewModel: transactionViewModel, portraitBottomSheetHeight: self.portraitBottomSheetHeight, buttonHeightPlusTopSpace: self.buttonHeightPlusTopSpace, buttonBottomSafeArea: self.buttonBottomSafeArea)
                        }
                    }.frame(maxHeight: .infinity, alignment: .bottom)
                    
                    if authViewModel.authState != .magicLink { AuthenticationHeader(viewModel: viewModel) }
                }
            }
            
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width, height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : viewModel.isCreditCardView ? dynamicHeight + 72 : viewModel.purchaseState == .login && keyboardObserver.isKeyboardVisible ? self.setHeightFromKeyboardToTop(keyboardObserverHeight: keyboardObserver.heighFromKeyboardToTop) : portraitBottomSheetHeight)
        .padding(.bottom, keyboardObserver.isKeyboardVisible && viewModel.orientation != .landscape ? keyboardObserver.keyboardHeight: 0)
        .background(ColorsUi.APC_BottomSheet_LightGray_Background)
        .cornerRadius(13, corners: [.topLeft, .topRight])
        .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
        .transition(.move(edge: isPresented ? .bottom : .top))
        .onAppear { withAnimation { isPresented = true } }
    }
    
    private func startObservingDynamicHeight() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { timer in
            if let viewController = adyenController.presentableComponent?.viewController {
                for view in viewController.view.subviews {
                    for subview in view.subviews {
                        if let content = subview.subviews.first {
                            if content.bounds.height != dynamicHeight && content.bounds.height != 0 {
                                DispatchQueue.main.async {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        dynamicHeight = content.bounds.height
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func stopObservingDynamicHeight() {
        timer?.invalidate()
        timer = nil
    }
    
    private func setHeightFromKeyboardToTop(keyboardObserverHeight: CGFloat) -> CGFloat {
        if keyboardObserverHeight > portraitBottomSheetHeight {
            return portraitBottomSheetHeight
        } else {
            return keyboardObserverHeight
        }
    }
}
