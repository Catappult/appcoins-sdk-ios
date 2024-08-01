//
//  ErrorBottomSheet.swift
//  
//
//  Created by aptoide on 08/03/2023.
//

import Foundation
import SwiftUI
import URLImage

internal struct ErrorBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @State private var toast: FancyToast? = nil
    @State var address: String?
    
    internal var body: some View {

        ZStack {
            APPCColor.darkBlue
                
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
                    .foregroundColor(APPCColor.white)
                    .padding(.top, 16)
                
                Text(viewModel.purchaseFailedMessage)
                    .font(FontsUi.APC_Footnote)
                    .foregroundColor(APPCColor.white)
                    .padding(.top, 15)
                
                Button(action: {
                    var subject: String
                    
                    if let address = address { subject = "[iOS] Payment Support: \(address)" }
                    else { subject = "[iOS] Payment Support" }
                    
                    if let subject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                        let emailURL = URL(string: "mailto:info@appcoins.io?subject=\(subject)") {
                        UIApplication.shared.open(emailURL)
                    } else {
                        toast = FancyToast(type: .info, title: Constants.supportAvailableSoonTitle, message: Constants.supportAvailableSoonMessage)
                    }
                }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .edgesIgnoringSafeArea(.all)
                            .foregroundColor(APPCColor.white)
                            .frame(width: 20, height: 20)
                        
                        Text(Constants.appcSupport)
                            .font(FontsUi.APC_Body_Bold)
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 64, height: 48)
                .background(APPCColor.opaqueBlack)
                .foregroundColor(APPCColor.white)
                .cornerRadius(10)
                .padding(.top, 36)
                
                Button(action: { viewModel.dismiss() }) {
                    Text(Constants.cancelText)
                        .foregroundColor(APPCColor.darkGray)
                        .font(FontsUi.APC_Footnote_Bold)
                        .lineLimit(1)
                }
                .padding(.top, 12)
                .padding(.bottom, 20)

            }.frame(height: 396, alignment: .top)
            
        }.frame(width: UIScreen.main.bounds.size.width, height: 396)
            .cornerRadius(13, corners: [.topLeft, .topRight])
            .toastView(toast: $toast)
            .onAppear {
                WalletUseCases.shared.getWallet() { result in
                    switch result {
                    case .success(let wallet):
                        self.address = wallet.getWalletAddress()
                    case .failure(let failure):
                        break
                    }
                }
            }
        
    }
}
