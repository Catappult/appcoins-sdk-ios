//
//  File.swift
//  
//
//  Created by aptoide on 27/12/2024.
//

import SwiftUI

struct PayingViewFormLayer: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    @State var formLayerID: UUID = UUID()
    
    internal var body: some View {
        VStack(spacing: 0) {
            if #available(iOS 17.0, *) {
                PurchaseViewWrapper(height: viewModel.orientation == .landscape ? (UIScreen.main.bounds.height * 0.9) - 78 - 72 : 420 - 78 - 72, offset: 72) {
                    VStack(spacing: 0) {
                        PurchaseBonusBanner(viewModel: viewModel, transactionViewModel: transactionViewModel, authViewModel: authViewModel)
                        
                        VStack{}.frame(height: 16)
                        
                        if let paymentMethodSelected = transactionViewModel.paymentMethodSelected { PaymentMethodSelectedBanner(paymentMethodSelected: paymentMethodSelected) }
                        
                        VStack{}.frame(height: 8)
                        
                        SelectPaymentMethodButton()
                        
                        if !authViewModel.isLoggedIn {
                            VStack{}.frame(height: 8)
                            
                            LoginButton(action: { viewModel.setPurchaseState(newState: .login) }, orientation: viewModel.orientation)
                        }
                    }.ignoresSafeArea(.all)
                }.onChange(of: viewModel.isPaymentMethodChoiceSheetPresented) { isPresented in if !isPresented { formLayerID = UUID() } }
                    .id(formLayerID)
            }
            
            HStack{}.frame(height: 78)
        }
    }
}
