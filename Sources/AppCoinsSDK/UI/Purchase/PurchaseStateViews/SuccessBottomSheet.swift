//
//  SuccessBottomSheet.swift
//  
//
//  Created by aptoide on 08/03/2023.
//

import Foundation
import SwiftUI
import URLImage

struct SuccessBottomSheet: View {
    
    @ObservedObject var viewModel: BottomSheetViewModel
    
    var body: some View {

        Button(action: { viewModel.dismiss() }) {
            ZStack {
                ColorsUi.APC_DarkBlue
                
                VStack(spacing: 0) {
                    
                    Image("logo-wallet-white", bundle: Bundle.module)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 83, height: 24)
                        .padding(.top, 24)
                    
                    Image("checkmark", bundle: Bundle.module)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 80, height: 80)
                        .padding(.top, 40)
                    
                    Text(Constants.successText)
                        .font(FontsUi.APC_Title3_Bold)
                        .foregroundColor(ColorsUi.APC_White)
                        .padding(.top, 15)
                    
                    HStack {
                        Image("gift-1", bundle: Bundle.module)
                            .resizable()
                            .edgesIgnoringSafeArea(.all)
                            .frame(width: 17, height: 17)
                        
                        Text(String(format: Constants.bonusReceived, "\(viewModel.transaction?.bonusCurrency ?? "")\(String(format: "%.2f", viewModel.transaction?.bonusAmount ?? 0.0))"))
                            .font(FontsUi.APC_Subheadline_Bold)
                            .foregroundColor(ColorsUi.APC_White)
                            .frame(alignment: .bottom)
                            
                    }.padding(.top, 23)
                    
                    HStack(spacing: 0) {
                        Image("pink-wallet", bundle: Bundle.module)
                            .resizable()
                            .edgesIgnoringSafeArea(.all)
                            .frame(width: 19, height: 16)
                        Text(Constants.walletBalance)
                            .font(FontsUi.APC_Caption1_Bold)
                            .foregroundColor(ColorsUi.APC_Pink)
                            .padding(.leading, 6.22)
                        if let balance = viewModel.finalWalletBalance {
                            Text(balance)
                                .font(FontsUi.APC_Caption1_Bold)
                                .foregroundColor(ColorsUi.APC_White)
                        } else {
                            Text("0.00€")
                                .skeleton(with: true)
                                .font(FontsUi.APC_Caption1_Bold)
                                .opacity(0.1)
                                .frame(width: 35, height: 15)
                        }
                    }.padding(.top, 24)
                        .padding(.bottom, 56)
                    
                    
                }.frame(height: 348, alignment: .top)
                
                
            }.frame(width: UIScreen.main.bounds.size.width, height: 348)
                .cornerRadius(13, corners: [.topLeft, .topRight])
        }
                
    }
}