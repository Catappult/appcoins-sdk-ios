//
//  PurchaseBottomSheet.swift
//
//
//  Created by aptoide on 31/08/2023.
//

import Foundation
import SwiftUI

internal struct PurchaseBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    
    @State private var timer: Timer? = nil
    @State internal var dynamicHeight: CGFloat = 291
    
    internal let buttonHeightPlusTopSpace: CGFloat = 58
    internal let bottomSheetHeaderHeight: CGFloat = 72
    internal let buttonBottomSafeArea: CGFloat = Utils.bottomSafeAreaHeight == 0 ? 5 : 28
    
    internal var body: some View {
        
        PurchaseBottomSheetWrapper(
            dynamicHeight: self.$dynamicHeight,
            header: {
                switch viewModel.purchaseState {
                case .loading:
                    PayingHeader()
                case .paying:
                    PayingHeader()
                case .adyen:
                    switch adyenController.state {
                    case .choosingCreditCard, .newCreditCard:
                        PayingHeader()
                    default:
                        EmptyView()
                    }
                case .login:
                    switch authViewModel.authState {
                    case .choice:
                        AuthenticationHeader()
                    case .magicLink, .error, .noInternet:
                        DismissHeader()
                    default:
                        EmptyView()
                    }
                default:
                    EmptyView()
                }
            },
            content: {
                switch viewModel.purchaseState {
                case .loading:
                    APPCLoading()
                case .paying:
                    PayingView()
                case .adyen:
                    switch adyenController.state {
                    case .none:
                        APPCLoading()
                    case .choosingCreditCard:
                        CreditCardChoiceView()
                    case .newCreditCard:
                        CreditCardFormView(dynamicHeight: $dynamicHeight, startObservingDynamicHeight: startObservingDynamicHeight, stopObservingDynamicHeight: stopObservingDynamicHeight)
                    default:
                        EmptyView()
                    }
                case .login:
                    switch authViewModel.authState {
                    case .choice:
                        LoginView()
                    case .google:
                        EmptyView()
                    case .magicLink:
                        MagicLinkView()
                    case .loading:
                        APPCLoading()
                    case .success:
                        SuccessLoginView()
                    case .error:
                        ErrorLoginView()
                    case .noInternet:
                        NoInternetLoginView()
                    }
                default:
                    EmptyView()
                }
            }
        )
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
    
}
