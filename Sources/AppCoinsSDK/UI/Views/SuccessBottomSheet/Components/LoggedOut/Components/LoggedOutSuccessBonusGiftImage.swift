//
//  LoggedOutSuccessBonusGiftImage.swift
//
//
//  Created by aptoide on 03/01/2025.
//

import SwiftUI

internal struct LoggedOutSuccessBonusGiftImage: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    internal var body: some View {
        Image("bonus-gift", bundle: Bundle.APPCModule)
            .resizable()
            .edgesIgnoringSafeArea(.all)
            .frame(
                width: viewModel.orientation == .landscape ? 92 : 106,
                height: viewModel.orientation == .landscape ? 127 : 146
            )
    }
}
