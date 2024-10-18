//
//  PurchaseBonusBanner.swift
//
//
//  Created by Graciano Caldeira on 14/10/2024.
//

import SwiftUI

struct PurchaseBonusBanner: View {
    
    @ObservedObject var viewModel: BottomSheetViewModel
    @ObservedObject var transactionViewModel: TransactionViewModel
    
    var body: some View {
        if transactionViewModel.paymentMethodSelected != nil && transactionViewModel.paymentMethodSelected?.name != Method.appc.rawValue && transactionViewModel.paymentMethodSelected?.name != Method.sandbox.rawValue {
            VStack(spacing: 0) {
                
                VStack {}.frame(height: 10)
                
                HStack {
                    Image("gift-pink", bundle: Bundle.module)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 16, height: 16)
                    
                    if let bonusCurrency = transactionViewModel.transaction?.bonusCurrency.sign, let bonusAmount = transactionViewModel.transaction?.bonusAmount {
                        Text(String(format: Constants.purchaseBonus, "\(bonusCurrency)\(String(format: "%.3f", bonusAmount))"))
                            .font(FontsUi.APC_Caption1_Bold)
                            .foregroundColor(ColorsUi.APC_White)
                            .frame(height: 16)
                    } else {
                        HStack(spacing: 0) {
                            Text("")
                                .skeleton(with: true)
                                .font(FontsUi.APC_Caption1_Bold)
                                .opacity(0.1)
                                .frame(width: 40, height: 17)
                        }
                    }
                    
                    Image("appc-payment-method-pink", bundle: Bundle.module)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 16, height: 16)
                }
                
                VStack {}.frame(height: 4)
                
                Text(Constants.canSeeBonusText)
                    .font(FontsUi.APC_Caption2)
                    .foregroundColor(ColorsUi.APC_Gray)
                    .frame(height: 13)
                
                VStack {}.frame(height: 10)
                
            }
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 56)
            .background(ColorsUi.APC_DarkBlue)
            .cornerRadius(12)
            
        }
    }
}
