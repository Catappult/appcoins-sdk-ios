//
//  MagicLinkView.swift
//
//
//  Created by Graciano Caldeira on 28/11/2024.
//

import SwiftUI

internal struct MagicLinkView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal var magicLinkCounterLabelHeight: CGFloat {
        String(format: Constants.resendInTime, "30")
            .height(
                withConstrainedWidth: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48,
                font: UIFont.systemFont(ofSize: 15, weight: .regular)
            )
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
            HStack{}.frame(maxHeight: .infinity)
            HStack{}.frame(maxHeight: .infinity) // This will make the top spacing take double the space as the middle spacing
            
            MagicLinkImage()
            
            HStack{}.frame(height: 16)
            
            MagicLinkLabel()
            
            HStack{}.frame(maxHeight: .infinity)
            
            VStack(spacing: 0) {
                if authViewModel.retryMagicLinkIn != 0 {
                    MagicLinkCounter()
                    
                    HStack{}.frame(height: 8)
                    
                    MagicLinkCounterLabel(magicLinkCounterLabelHeight: magicLinkCounterLabelHeight)
                }
            }.frame(height: 32 + magicLinkCounterLabelHeight)
            
            HStack{}.frame(height: 16)
            
            ResendMagicLinkButton()
            
            HStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
        }.frame(maxWidth: .infinity, alignment: .top)
        
    }
}
