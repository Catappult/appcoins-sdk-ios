//
//  SyncErrorBottomSheet.swift
//
//
//  Created by aptoide on 13/10/2023.
//

import Foundation
import SwiftUI

internal struct SyncErrorBottomSheet: View {
    
    @ObservedObject internal var viewModel: SyncWalletViewModel = SyncWalletViewModel.shared
    
    internal var body: some View {

        ZStack {
            ColorsUi.APC_DarkBlue
            
            VStack(spacing: 0) {
                
                VStack{}.frame(height: 66)
                
                Image("exclamation-red", bundle: Bundle.APPCModule)
                    .resizable()
                    .frame(width: 80, height: 80)
                
                VStack{}.frame(height: 15)
                
                Text(Constants.somethingWentWrongShort)
                    .font(FontsUi.APC_Title3_Bold)
                    .foregroundColor(ColorsUi.APC_White)
                    .frame(height: 25)
                
            }.frame(height: 314 + Utils.bottomSafeAreaHeight, alignment: .top)
            
        }
        .frame(width: UIScreen.main.bounds.size.width, height: 436)
        .cornerRadius(13, corners: [.topLeft, .topRight])
        .offset(y: viewModel.syncDismissAnimation ? 0 : 436)
        .transition(viewModel.syncDismissAnimation ? .identity : .move(edge: .top))
        .animation(.easeOut(duration: 0.5))
    }
}
