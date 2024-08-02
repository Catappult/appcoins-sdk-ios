//
//  InitialSyncBottomSheet.swift
//  
//
//  Created by aptoide on 10/10/2023.
//

import Foundation
import SwiftUI
import URLImage

internal struct InitialSyncBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    
    internal var body: some View {

        ZStack {
            APPCColor.darkBlue

            Image("wallet-sync-shades", bundle: Bundle.module)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .frame(width: UIScreen.main.bounds.size.width)
            
            VStack(spacing: 0) {
                
                Image("wallet-sync-graphic", bundle: Bundle.module)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: 200, height: 144)
                    .padding(.top, 50)
                
                Text(Constants.titleWalletInitialSync)
                    .font(FontsUi.APC_Title3_Bold)
                    .foregroundColor(APPCColor.white)
                    .multilineTextAlignment(.center)
                    .frame(width: 296, height: 56)
                    .padding(.top, 14)

                Image("wallet-not-synced-icon", bundle: Bundle.module)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: 32, height: 32)
                    .padding(.top, 32)
                    
                VStack(spacing: 0) {
                    Text(Constants.subtitleWalletInitialSync)
                        .font(FontsUi.APC_Caption1_Bold)
                        .foregroundColor(APPCColor.white)
                        .multilineTextAlignment(.center)
                    
                    StyledText(
                        Constants.bodyWalletInitialSync,
                        textStyle: FontsUi.APC_Caption1,
                        boldStyle: FontsUi.APC_Caption1_Bold,
                        textColorRegular: APPCColor.white,
                        textColorBold: APPCColor.pink)
                        .multilineTextAlignment(.center)
                }.frame(width: 280, height: 48)
                .padding(.top, 16)
                
                Button(action: SyncWalletViewModel.shared.importWallet) {
                    ZStack {
                        APPCColor.pink
                        
                        Text(Constants.syncWallet)
                            .font(FontsUi.APC_Body_Bold)
                            .foregroundColor(APPCColor.white)
                    }
                    .frame(width: UIScreen.main.bounds.size.width - 48, height: 48)
                    .cornerRadius(10)
                    .padding(.top, 24)
                }

                Button(action: viewModel.skipWalletSync) {
                    Text(Constants.skipAndBuy)
                        .font(FontsUi.APC_Footnote_Bold)
                        .foregroundColor(APPCColor.white)
                        .padding(.top, 14)
                }
                    
            }.frame(height: 506 + Utils.bottomSafeAreaHeight, alignment: .top)
            
            
        }.frame(width: UIScreen.main.bounds.size.width, height: 506 + Utils.bottomSafeAreaHeight)
            .cornerRadius(13, corners: [.topLeft, .topRight])
            .offset(y: viewModel.isInitialSyncSheetPresented ? 0 : UIScreen.main.bounds.height)
            .transition(.move(edge: viewModel.isInitialSyncSheetPresented ? .bottom : .top))
            .onAppear { withAnimation { viewModel.isInitialSyncSheetPresented = true } }
        
    }
}
