//
//  DeleteAccountSuccessView.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/05/2025.
//

import SwiftUI

internal struct DeleteAccountSuccessView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    
    internal var body: some View {
        ZStack {
            Image("checkmark", bundle: Bundle.APPCModule)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .frame(width: 50, height: 50)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.width, height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : 420)
        .ignoresSafeArea(.all)
        .animation(.easeInOut(duration: 0.2))
    }
}
