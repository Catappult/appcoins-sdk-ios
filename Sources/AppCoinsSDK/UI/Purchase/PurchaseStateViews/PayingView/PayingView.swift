//
//  PurchaseView.swift
//
//
//  Created by Graciano Caldeira on 04/10/2024.
//

import SwiftUI
@_implementationOnly import ActivityIndicatorView

struct PayingView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal let portraitBottomSheetHeight: CGFloat = 420 // I don't like this
    
    internal var formLayer: some View {
        VStack(spacing: 0) {
            PurchaseViewWrapper(height: viewModel.orientation == .landscape ? (UIScreen.main.bounds.height * 0.9) - 78 - 72 : 420, offset: 72) {
                VStack(spacing: 0) {
                    PurchaseBonusBanner(viewModel: viewModel, transactionViewModel: transactionViewModel, authViewModel: authViewModel)
                    
                    VStack{}.frame(height: 16)
                    
                    if let paymentMethodSelected = transactionViewModel.paymentMethodSelected { PaymentMethodSelectedBanner(paymentMethodSelected: paymentMethodSelected) }
                    
                    VStack{}.frame(height: 8)
                    
                    SelectPaymentMethodButton()
                    
                    if !authViewModel.isLoggedIn {
                        VStack{}.frame(height: 8)
                        
                        LoginButton()
                    }
                }.ignoresSafeArea(.all)
            }
            
            HStack{}.frame(height: 78)
        }
        
    }
    
    internal var buttonLayer : some View {
        VStack(spacing: 0) {
            HStack{}.frame(maxHeight: .infinity)
            
            // Buying button
            Button(action: {
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
            
            VStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
        }
    }
    
    internal var body: some View {
        ZStack {
            formLayer
            buttonLayer
        }.frame(maxHeight: .infinity, alignment: .bottom)
            
    }
}
