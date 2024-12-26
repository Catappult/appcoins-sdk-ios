//
//  MagicLinkCodeView.swift
//
//
//  Created by Graciano Caldeira on 28/11/2024.
//

import SwiftUI

struct MagicLinkView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var authViewModel: AuthViewModel
    @ObservedObject internal var transactionViewModel: TransactionViewModel
    
    internal let portraitBottomSheetHeight: CGFloat
    internal let buttonHeightPlusTopSpace: CGFloat
    internal let buttonBottomSafeArea: CGFloat
    
//    @State private var shouldFocusTextField: Bool = false
    
    var body: some View {
        if #available(iOS 17, *) {
            ZStack(alignment: .top) {
                PurchaseViewWrapper(height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : portraitBottomSheetHeight, buttonHeightPlusTopSpace: buttonHeightPlusTopSpace, buttonBottomSafeArea: buttonBottomSafeArea, magicLinkCodeViewTopSpace: viewModel.orientation == .landscape ? 40 : 56) {
                    
                    VStack(spacing: 0) {
                        
                        Image("magic-link-image", bundle: Bundle.APPCModule)
                            .resizable()
                            .frame(width: 105, height: 72)
                        
                        VStack{}.frame(height: 16)
                        
                        Text(Constants.checkYourEmail)
                            .font(FontsUi.APC_Title3_Bold)
                            .foregroundColor(ColorsUi.APC_Black)
                        
                        VStack{}.frame(height: 16)
                        
                        Text(Constants.sentCodeTo + ": " + authViewModel.magicLinkEmail)
                            .font(FontsUi.APC_Subheadline)
                            .foregroundColor(ColorsUi.APC_Black)
                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 30 : UIScreen.main.bounds.width - 48 - 30)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
                
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        
                        VStack{}.frame(height: 21)
                        
                        CloseButton(action: viewModel.dismiss)
                    }
                }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 51, alignment: .topTrailing)
                
                VStack(spacing: 0) {
                    if authViewModel.retryMagicLinkIn != 0 {
                        Text(String(format: Constants.resendInTime, String(authViewModel.retryMagicLinkIn)))
                            .font(FontsUi.APC_Subheadline)
                            .foregroundColor(ColorsUi.APC_Black)
                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 30 : UIScreen.main.bounds.width - 48 - 30)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    
                    VStack{}.frame(height: 8)
                    
                    Button(action: {
                        authViewModel.sendMagicLink()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(authViewModel.retryMagicLinkIn != 0 ? ColorsUi.APC_Gray : ColorsUi.APC_Pink)
                            if authViewModel.isSendingMagicLink {
                                ProgressView().tint(ColorsUi.APC_White)
                            } else {
                                Text(Constants.resendEmail)
                            }
                        }
                    }
                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                    .foregroundColor(ColorsUi.APC_White)
                    .disabled(authViewModel.retryMagicLinkIn != 0)
                    
                    VStack{}.frame(height: buttonBottomSafeArea)
                    
                }.frame(maxHeight: .infinity, alignment: .bottom)
                .animation(.easeInOut(duration: 0.15))
                
            }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, alignment: .center)
        }
    }
}
