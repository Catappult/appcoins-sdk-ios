//
//  SuccessAskForSyncBottomSheet.swift
//  
//
//  Created by aptoide on 12/10/2023.
//

import Foundation
import SwiftUI
import URLImage

internal struct SuccessAskForSyncBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    internal var body: some View {

        ZStack {
            ColorsUi.APC_DarkBlue
            
            Image("wallet-sync-shades-2", bundle: Bundle.module)
                .resizable()
                .edgesIgnoringSafeArea(.all)
        
            VStack(spacing: 0) {
                    
                Image("checkmark", bundle: Bundle.module)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: 48, height: 48)
                    .padding(.top, 40)
                
                Text(Constants.successText)
                    .font(FontsUi.APC_Title3_Bold)
                    .foregroundColor(ColorsUi.APC_White)
                    .frame(width: 200, height: 24)
                    .padding(.top, 8)
                
                if transactionViewModel.paymentMethodSelected?.name != Method.appc.rawValue {
                    HStack {
                        Image("gift-1", bundle: Bundle.module)
                            .resizable()
                            .edgesIgnoringSafeArea(.all)
                            .frame(width: 17, height: 17)
                        
                        Text(String(format: Constants.bonusReceived, "\(transactionViewModel.transaction?.bonusCurrency ?? "")\(String(format: "%.2f", transactionViewModel.transaction?.bonusAmount ?? 0.0))"))
                            .font(FontsUi.APC_Subheadline_Bold)
                            .foregroundColor(ColorsUi.APC_White)
                            .frame(alignment: .bottom)
                            
                    }
                    .frame(height: 17)
                    .padding(.top, 8)
                } else {
                    HStack {}
                        .frame(height: 17)
                        .padding(.top, 8)
                }
                
                Image("wallet-sync-graphic", bundle: Bundle.module)
                    .resizable()
                    .frame(width: 200, height: 144)
                    .padding(.top, 38)
                
                
                VStack(spacing: 0) {
                    Text(Constants.subtitleWalletInitialSync)
                        .font(FontsUi.APC_Caption1_Bold)
                        .foregroundColor(ColorsUi.APC_White)
                        .multilineTextAlignment(.center)
                    
                    StyledText(
                        Constants.bodyWalletInitialSync,
                        textStyle: FontsUi.APC_Caption1,
                        boldStyle: FontsUi.APC_Caption1_Bold,
                        textColorRegular: ColorsUi.APC_White,
                        textColorBold: ColorsUi.APC_Pink)
                        .multilineTextAlignment(.center)
                }.frame(width: 296, height: 48)
                .padding(.top, 16)
            
                Button(action: SyncWalletViewModel.shared.importWallet) {
                    ZStack {
                        ColorsUi.APC_Pink
                        
                        Text(Constants.syncWallet)
                            .font(FontsUi.APC_Body_Bold)
                            .foregroundColor(ColorsUi.APC_White)
                    }
                    .frame(width: UIScreen.main.bounds.size.width - 48, height: 48)
                    .cornerRadius(10)
                    .padding(.top, 24)
                }

                Button(action: viewModel.skipWalletSync) {
                    Text(Constants.skip)
                        .font(FontsUi.APC_Footnote_Bold)
                        .foregroundColor(ColorsUi.APC_White)
                        .padding(.top, 14)
                }
                
            }.frame(width: UIScreen.main.bounds.size.width, height: 506 + Utils.bottomSafeAreaHeight, alignment: .top)
            
        }.frame(width: UIScreen.main.bounds.size.width, height: 506 + Utils.bottomSafeAreaHeight)
            .cornerRadius(13, corners: [.topLeft, .topRight])
            .offset(y: viewModel.successSyncAnimation ? 0 : UIScreen.main.bounds.height)
            .transition(.move(edge: viewModel.successSyncAnimation ? .bottom : .top))
            .onAppear{ viewModel.successSyncAnimation = true }
            .animation(.easeInOut(duration: 0.5))
        
    }
}
