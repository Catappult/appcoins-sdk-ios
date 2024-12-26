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

internal struct PurchaseBottomSheetWrapper<Header: View, Body: View>: View {
    
    @State private var isPresented = false
        
    internal let header: () -> Header
    internal let content: () -> Body
    
    init(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Body
    ) {
        self.header = header
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            self.header()
            self.content()
        }
        .background(ColorsUi.APC_BottomSheet_LightGray_Background)
        .cornerRadius(13, corners: [.topLeft, .topRight])
        .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
        .transition(.move(edge: isPresented ? .bottom : .top))
        .onAppear { withAnimation { isPresented = true } }
    }
}

internal struct PurchaseBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    
    @ObservedObject private var keyboardObserver = KeyboardObserver.shared
    
    @State private var timer: Timer? = nil
    @State private var dynamicHeight: CGFloat = 291
    
    internal let portraitBottomSheetHeight: CGFloat = 420
    internal let buttonHeightPlusTopSpace: CGFloat = 58
    internal let bottomSheetHeaderHeight: CGFloat = 72
    internal let buttonBottomSafeArea: CGFloat = Utils.bottomSafeAreaHeight == 0 ? 5 : 28
    
    internal var body: some View {
        
        PurchaseBottomSheetWrapper(
            header: {
                BottomSheetAppHeader(viewModel: viewModel, transactionViewModel: transactionViewModel)
            },
            content: {
                PurchaseView(viewModel: viewModel, portraitBottomSheetHeight: self.portraitBottomSheetHeight, buttonHeightPlusTopSpace: self.buttonHeightPlusTopSpace, bottomSheetHeaderHeight: self.bottomSheetHeaderHeight, buttonBottomSafeArea: buttonBottomSafeArea)
            }
        )
        .frame(
            width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width,
            height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 :
                viewModel.isCreditCardView ? dynamicHeight + 72 :
                viewModel.purchaseState == .login && keyboardObserver.isKeyboardVisible ? self.setHeightFromKeyboardToTop(keyboardObserverHeight: keyboardObserver.heighFromKeyboardToTop) :
                portraitBottomSheetHeight,
            alignment: .center)
        .padding(.bottom, keyboardObserver.isKeyboardVisible && viewModel.orientation != .landscape ? keyboardObserver.keyboardHeight: 0)
        
//        switch viewModel.purchaseState {
//        case .paying:
//            PurchaseView(viewModel: viewModel, portraitBottomSheetHeight: self.portraitBottomSheetHeight, buttonHeightPlusTopSpace: self.buttonHeightPlusTopSpace, bottomSheetHeaderHeight: self.bottomSheetHeaderHeight, buttonBottomSafeArea: buttonBottomSafeArea)
//            
//        case .adyen:
//            switch adyenController.state {
//            case .none:
//                AdyenLoadingBottomSheet(viewModel: viewModel)
//            
//            case .choosingCreditCard:
//                CreditCardChoiceBottomSheet(viewModel: viewModel)
//
//            case .newCreditCard:
//                CreditCardFormBottomSheet(viewModel: viewModel, transactionViewModel: transactionViewModel, authViewModel: authViewModel, dynamicHeight: $dynamicHeight, startObservingDynamicHeight: startObservingDynamicHeight, stopObservingDynamicHeight: stopObservingDynamicHeight)
//            
//            default:
//                EmptyView()
//            }
//            
//        case .login:
//            ZStack(alignment: .top) {
//                VStack(spacing: 0) {
//                    switch authViewModel.authState {
//                    case .choice:
//                        LoginView(viewModel: viewModel, authViewModel: authViewModel, transactionViewModel: transactionViewModel, portraitBottomSheetHeight: self.portraitBottomSheetHeight, buttonHeightPlusTopSpace: self.buttonHeightPlusTopSpace, bottomSheetHeaderHeight: self.bottomSheetHeaderHeight, buttonBottomSafeArea: buttonBottomSafeArea)
//                    case .google:
//                        EmptyView()
//                    case .magicLink:
//                        MagicLinkView(viewModel: viewModel, authViewModel: authViewModel, transactionViewModel: transactionViewModel, portraitBottomSheetHeight: self.portraitBottomSheetHeight, buttonHeightPlusTopSpace: self.buttonHeightPlusTopSpace, buttonBottomSafeArea: self.buttonBottomSafeArea)
//                    case .loading:
//                        LoadingLoginView()
//                    case .success:
//                        SuccessLoginView()
//                    case .error:
//                        ErrorLoginView(viewModel: viewModel)
//                    }
//                }.frame(maxHeight: .infinity, alignment: .bottom)
//                
//                if authViewModel.authState == .choice { AuthenticationHeader(viewModel: viewModel) }
//            }
//            
//        default: EmptyView()
//        }
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
