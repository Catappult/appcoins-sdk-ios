//
//  ErrorBottomSheet.swift
//
//
//  Created by aptoide on 08/03/2023.
//

import Foundation
import SwiftUI

internal struct ErrorBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @State private var toast: FancyToast? = nil
    @State var address: String?
    
    internal var body: some View {
        ZStack {
            ColorsUi.APC_BottomSheet_LightGray_Background
            VStack(spacing: 0) {
                VStack{}.frame(height: 16)
                
                HStack(spacing: 0) {
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
                    }.frame(maxWidth: .infinity, alignment: .topTrailing)
                    
                    VStack{}.frame(width: 24)
                    
                }
                
                VStack{}.frame(height: viewModel.orientation == .landscape ? 21 : 68)
                
                Image("exclamation-red", bundle: Bundle.APPCModule)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: 80, height: 80)
                
                VStack{}.frame(height: 16)
                
                Text(Constants.errorText)
                    .font(FontsUi.APC_Title3_Bold)
                    .foregroundColor(ColorsUi.APC_Black)
                
                VStack{}.frame(height: 16)
                
                Text(viewModel.purchaseFailedMessage)
                    .font(FontsUi.APC_Footnote)
                    .foregroundColor(ColorsUi.APC_Black)
                
                VStack{}.frame(height: viewModel.orientation == .landscape ? 21 : 61)
                
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
                            .foregroundColor(ColorsUi.APC_BackgroundLightGray_Button)
                        
                        Text(Constants.appcSupport)
                            .font(FontsUi.APC_Body_Bold)
                            .foregroundColor(ColorsUi.APC_Pink)
                    }
                }
                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                .frame(maxHeight: .infinity, alignment: .bottom)
                
                VStack{}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : 28)
            }
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width, height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : 420)
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
    }
}
