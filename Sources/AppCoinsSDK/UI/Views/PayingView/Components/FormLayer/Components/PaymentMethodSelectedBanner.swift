//
//  PaymentMethodSelectedBanner.swift
//  
//
//  Created by aptoide on 26/12/2024.
//

import SwiftUI

internal struct PaymentMethodSelectedBanner: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var paypalDirectViewModel: PayPalDirectViewModel = PayPalDirectViewModel.shared
    
    internal var paymentMethodSelected: PaymentMethod
    
    internal var body: some View {
        HStack(spacing: 0) {
            VStack{}.frame(width: 16)
            
            PaymentMethodIcon(icon: paymentMethodSelected.icon, disabled: false)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(width: 24, height: 24)
            
            VStack{}.frame(width: 16)
            
            Text(paymentMethodSelected.label)
                .font(FontsUi.APC_Body)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if transactionViewModel.paymentMethodSelected?.name == Method.paypalDirect.rawValue {
                if transactionViewModel.isPaypalLogOutPresented {
                    Button(action: paypalDirectViewModel.showPayPalLogoutAlert) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .resizable()
                            .foregroundColor(ColorsUi.APC_DarkGray_Xmark.opacity(0.3))
                            .frame(width: 18, height: 22)
                    }
                } else if transactionViewModel.isPaypalLogOutLoadingPresented {
                    ProgressView()
                }
            }
            
            VStack{}.frame(width: 24)
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 64)
        .background(ColorsUi.APC_White)
        .cornerRadius(10)
    }
}
