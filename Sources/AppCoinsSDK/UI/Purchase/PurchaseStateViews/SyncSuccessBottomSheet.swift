//
//  SyncSuccessBottomSheet.swift
//  
//
//  Created by aptoide on 13/10/2023.
//

import Foundation
import SwiftUI
import URLImage

internal struct SyncSuccessBottomSheet: View {
    
    @ObservedObject internal var viewModel: SyncWalletViewModel = SyncWalletViewModel.shared
    
    internal var body: some View {

        ZStack {
            APPCColor.darkBlue
            
            VStack(spacing: 0) {
                
                Image("logo-wallet-white", bundle: Bundle.module)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: 83, height: 24)
                    .padding(.top, 24)
                
                Image("checkmark", bundle: Bundle.module)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding(.top, 66)
                
                Text(Constants.successText)
                    .font(FontsUi.APC_Title3_Bold)
                    .foregroundColor(APPCColor.white)
                    .frame(height: 25)
                    .padding(.top, 15)
                
            }.frame(height: 314 + Utils.bottomSafeAreaHeight, alignment: .top)
            
        }.frame(width: UIScreen.main.bounds.size.width, height: 314 + Utils.bottomSafeAreaHeight)
            .cornerRadius(13, corners: [.topLeft, .topRight])
            .offset(y: viewModel.syncDismissAnimation ? 0 : 314 + Utils.bottomSafeAreaHeight)
            .transition(viewModel.syncDismissAnimation ? .identity : .move(edge: .top))
            .animation(.easeOut(duration: 0.5))
                
    }
}
