//
//  AuthenticationHeader.swift
//
//
//  Created by Graciano Caldeira on 18/12/2024.
//

import SwiftUI

struct AuthenticationHeader: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            
            VStack{}.frame(width: 24)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(Constants.signInAndJoinTitle)
                    .foregroundColor(ColorsUi.APC_Black)
                    .font(FontsUi.APC_Callout_Bold)
                
                VStack{}.frame(height: 2)
                
                Text(Constants.getBonusEveryPurchase)
                    .foregroundColor(ColorsUi.APC_Black)
                    .font(FontsUi.APC_Footnote)
                
            }.frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
            
            Button {
                viewModel.dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(ColorsUi.APC_BackgroundLightGray_Button)
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: "xmark")
                        .foregroundColor(ColorsUi.APC_DarkGray_Xmark)
                }
            }
            
            VStack{}.frame(width: 24)
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.width, height: 72)
        .background(BlurView(style: .systemMaterial))
        .onTapGesture { UIApplication.shared.dismissKeyboard() }
    }
}
