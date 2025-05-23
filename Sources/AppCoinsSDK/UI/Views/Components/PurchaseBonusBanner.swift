//
//  PurchaseBonusBanner.swift
//
//
//  Created by Graciano Caldeira on 14/10/2024.
//

import SwiftUI

internal struct PurchaseBonusBanner: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var body: some View {
        HStack(spacing: 0) {
            
            VStack{}.frame(width: 16)
                
            if case let .regular(transaction) = transactionViewModel.transaction, transactionViewModel.hasBonus {
                HStack {
                    Image("gift-pink", bundle: Bundle.APPCModule)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 13, height: 14)
                    
                    StyledText(
                        String(format: Constants.purchaseBonus, "\(transaction.bonusCurrency.sign)\(String(format: "%.2f", transaction.bonusAmount))"),
                        textStyle: FontsUi.APC_Caption1_Bold,
                        boldStyle: FontsUi.APC_Caption1_Bold,
                        textColorRegular: ColorsUi.APC_White,
                        textColorBold: ColorsUi.APC_Pink
                    ).frame(height: 16)
                    
                    Image("appc-payment-method-white", bundle: Bundle.APPCModule)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 16, height: 16)
                }.frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack {
                    Image("gift-gray", bundle: Bundle.APPCModule)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 16, height: 16)
                    
                    Text(Constants.bonusNotAvailableText)
                        .font(FontsUi.APC_Caption1_Bold)
                        .foregroundColor(ColorsUi.APC_BottomSheet_APPC)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack{}.frame(width: 16)
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 40)
        .background(transactionViewModel.hasBonus ? ColorsUi.APC_DarkBlue : ColorsUi.APC_BonusBannerBackground)
        .animation(.easeInOut(duration: 0.2))
        .cornerRadius(12)
    }
}
