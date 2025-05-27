//
//  PayingViewFormLayer.swift
//
//
//  Created by aptoide on 27/12/2024.
//

import SwiftUI

internal struct PayingViewFormLayer: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    @State internal var formLayerID: UUID = UUID()
    
    internal var body: some View {
        VStack(spacing: 0) {
            if #available(iOS 17.0, *) {
                OverflowAnimationWrapper(height: viewModel.orientation == .landscape ? (UIScreen.main.bounds.height * 0.9) - 86 - 72 : 420 - 86 - 72, offset: 72) {
                    VStack(spacing: 0) {
                        if case let .regular(transaction) = transactionViewModel.transaction {
                            PurchaseBonusBanner()
                            
                            if authViewModel.isLoggedIn {
                                VStack{}.frame(height: 8)
                                
                                WalletBalanceBanner()
                            }
                            
                            VStack{}.frame(height: 16)
                        }
                        
                        if let paymentMethodSelected = transactionViewModel.paymentMethodSelected { PaymentMethodSelectedBanner(paymentMethodSelected: paymentMethodSelected) }
                        
                        VStack{}.frame(height: 8)
                        
                        SelectPaymentMethodButton()
                        
                        if !authViewModel.isLoggedIn, case let .regular(transaction) = transactionViewModel.transaction {
                            VStack{}.frame(height: 8)
                            
                            LoginButton(action: {
                                authViewModel.reset()
                                viewModel.setPurchaseState(newState: .login)
                            }, orientation: viewModel.orientation)
                        }
                    }.ignoresSafeArea(.all)
                }
                .onChange(of: viewModel.isPaymentMethodChoiceSheetPresented) { isPresented in if !isPresented { formLayerID = UUID() } }
                .onChange(of: viewModel.isManageAccountSheetPresented) { isPresented in if !isPresented { formLayerID = UUID() } }
                .onChange(of: authViewModel.isLoggedIn) { formLayerID = UUID() }
                .id(formLayerID)
            }
            
            HStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 63 : 86)
        }
    }
}
