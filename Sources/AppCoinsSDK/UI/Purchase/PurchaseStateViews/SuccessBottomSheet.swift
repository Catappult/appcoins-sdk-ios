//
//  SuccessBottomSheet.swift
//  
//
//  Created by aptoide on 08/03/2023.
//

import Foundation
import SwiftUI
import URLImage

internal struct SuccessBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    internal var body: some View {

        Button(action: { viewModel.dismiss() }) {
            ZStack {
                ColorsUi.APC_BottomSheet_LightGray_Background
                
                VStack(spacing: 0) {
                    
                    VStack {}.frame(height: viewModel.isLandscape ? 80 : 40)
                    
                    Image("checkmark", bundle: Bundle.module)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 80, height: 80)
                    
                    VStack {}.frame(height: 15)
                    
                    Text(Constants.successText)
                        .font(FontsUi.APC_Title3_Bold)
                        .foregroundColor(ColorsUi.APC_Black)
                    
                    if transactionViewModel.paymentMethodSelected?.name != Method.appc.rawValue {
                        
                        VStack {}.frame(height: 23)
                        
                        HStack {
                            Image("gift-black", bundle: Bundle.module)
                                .resizable()
                                .edgesIgnoringSafeArea(.all)
                                .frame(width: 17, height: 17)
                                
                            Text(String(format: Constants.bonusReceived, "\(transactionViewModel.transaction?.bonusCurrency.sign ?? "")\(String(format: "%.2f", transactionViewModel.transaction?.bonusAmount ?? 0.0))"))
                                .font(FontsUi.APC_Subheadline_Bold)
                                .foregroundColor(ColorsUi.APC_Black)
                                .frame(alignment: .bottom)
                                
                        }
                    } else {
                        
                        VStack {}.frame(height: 23)
                        
                        HStack {}
                            .frame(height: 17)
                    }
                    
                    VStack {}.frame(height: 24)
                    
                    HStack(spacing: 0) {
                        Image("pink-wallet", bundle: Bundle.module)
                            .resizable()
                            .edgesIgnoringSafeArea(.all)
                            .frame(width: 19, height: 16)
                        
                        if let balance = viewModel.finalWalletBalance {
                            
                            VStack {}.frame(width: 6.22)
                            
                            StyledText(
                                String(format: Constants.walletBalance, "*\(balance)*"),
                                textStyle: FontsUi.APC_Caption1_Bold,
                                boldStyle: FontsUi.APC_Caption1_Bold,
                                textColorRegular: ColorsUi.APC_Pink,
                                textColorBold: ColorsUi.APC_Pink)
                        } else {
                            
                            VStack {}.frame(width: 6.22)
                            
                            Text(String(format: Constants.walletBalance, ""))
                                .font(FontsUi.APC_Caption1_Bold)
                                .foregroundColor(ColorsUi.APC_Pink)
                            
                            Text("")
                                .skeleton(with: true)
                                .font(FontsUi.APC_Caption1_Bold)
                                .opacity(0.1)
                                .frame(width: 35, height: 15)
                        }
                    }
                    
                    VStack {}.frame(height: 56)
                    
                }.frame(height: 348, alignment: .top)
                
                
            }
            .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width, height: viewModel.isLandscape ? UIScreen.main.bounds.height * 0.9 : 420)
                .cornerRadius(13, corners: [.topLeft, .topRight])
        }
        .offset(y: viewModel.successAnimation ? 0 : 420)
        .transition(viewModel.successAnimation ? .identity : .move(edge: .top))
        .animation(.easeOut(duration: 0.5))
    }
}
