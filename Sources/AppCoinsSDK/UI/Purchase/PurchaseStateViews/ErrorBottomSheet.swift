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
            ColorsUi.APC_DarkBlue
            VStack(spacing: 0) {
                VStack {}.frame(height: 16)
                
                HStack(spacing: 0) {
                    Button {
                        viewModel.dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(ColorsUi.APC_BackgroundDarkGray_Button)
                                .frame(width: 30, height: 30)
                            
                            Image(systemName: "xmark")
                                .foregroundColor(ColorsUi.APC_LightGray_Xmark)
                            
                        }
                    }.frame(maxWidth: .infinity, alignment: .trailing)
                    
                    VStack {}.frame(width: 24)
                    
                }.frame(alignment: .topTrailing)
                
                VStack {}.frame(height: 68)
                
                    Image("exclamation-red", bundle: Bundle.module)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 80, height: 80)
                    
                    VStack {}.frame(height: 16)
                    
                    Text(Constants.errorText)
                        .font(FontsUi.APC_Title3_Bold)
                        .foregroundColor(ColorsUi.APC_White)
                    
                    VStack {}.frame(height: 16)
                    
                    Text(viewModel.purchaseFailedMessage)
                        .font(FontsUi.APC_Footnote)
                        .foregroundColor(ColorsUi.APC_White)
                
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
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(ColorsUi.APC_AppCoinsSupport_background_button)
                        
                        Text(Constants.appcSupport)
                            .font(FontsUi.APC_Body_Bold)
                            .foregroundColor(ColorsUi.APC_Pink)
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 48, height: 50)
                .frame(maxHeight: .infinity, alignment: .bottom)

                VStack {}.frame(height: 47)
            }
        }
        .cornerRadius(13, corners: [.topLeft, .topRight])
        .toastView(toast: $toast)
        .onAppear {
            WalletUseCases.shared.getWallet() { result in
                switch result {
                case .success(let wallet):
                    self.address = wallet.getWalletAddress()
                case .failure: break
                }
            }
        }
        .ignoresSafeArea(.all)
    }
}
