//
//  ErrorBottomSheet.swift
//  
//
//  Created by aptoide on 08/03/2023.
//

import Foundation
import SwiftUI
import URLImage

struct ErrorBottomSheet: View {
    
    @ObservedObject var viewModel: BottomSheetViewModel
    @State private var toast: FancyToast? = nil
    
    var body: some View {

        ZStack {
            ColorsUi.APC_DarkBlue
                
            VStack(spacing: 0) {
                
                Image("logo-wallet-white", bundle: Bundle.module)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: 83, height: 24)
                    .padding(.top, 24)
                
                Image("exclamation", bundle: Bundle.module)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: 80, height: 80)
                    .padding(.top, 40)
                
                Text(Constants.errorText)
                    .font(FontsUi.APC_Title3_Bold)
                    .foregroundColor(ColorsUi.APC_White)
                    .padding(.top, 16)
                
                Text(viewModel.purchaseFailedMessage)
                    .font(FontsUi.APC_Footnote)
                    .foregroundColor(ColorsUi.APC_White)
                    .padding(.top, 15)
                
                Button(action: {
                    toast = FancyToast(type: .info, title: Constants.supportAvailableSoonTitle, message: Constants.supportAvailableSoonMessage)
                }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .edgesIgnoringSafeArea(.all)
                            .foregroundColor(ColorsUi.APC_White)
                            .frame(width: 20, height: 20)
                        
                        Text(Constants.appcSupport)
                            .font(FontsUi.APC_Body_Bold)
                    }
                }
                .frame(width: 328, height: 48)
                .background(ColorsUi.APC_OpaqueBlack)
                .foregroundColor(ColorsUi.APC_White)
                .cornerRadius(10)
                .padding(.top, 36)
                
                Button(action: { viewModel.dismiss() }) {
                    Text(Constants.cancelText)
                        .foregroundColor(ColorsUi.APC_DarkGray)
                        .font(FontsUi.APC_Footnote_Bold)
                        .lineLimit(1)
                }
                .padding(.top, 12)
                .padding(.bottom, 20)

            }.frame(height: 396, alignment: .top)
            
        }.frame(width: UIScreen.main.bounds.size.width, height: 396)
            .cornerRadius(13, corners: [.topLeft, .topRight])
            .toastView(toast: $toast)
        
    }
}
