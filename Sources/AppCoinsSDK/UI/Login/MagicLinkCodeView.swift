//
//  MagicLinkCodeView.swift
//
//
//  Created by Graciano Caldeira on 28/11/2024.
//

import SwiftUI

struct MagicLinkCodeView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var authViewModel: AuthViewModel
    @ObservedObject internal var transactionViewModel: TransactionViewModel
    
    internal let portraitBottomSheetHeight: CGFloat
    internal let buttonHeightPlusTopSpace: CGFloat
    internal let buttonBottomSafeArea: CGFloat
    
    @State private var shouldFocusTextField: Bool = false
    
    var body: some View {
        if #available(iOS 17, *) {
            ZStack(alignment: .top) {
                PurchaseViewWrapper(height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : portraitBottomSheetHeight, buttonHeightPlusTopSpace: buttonHeightPlusTopSpace, buttonBottomSafeArea: buttonBottomSafeArea, magicLinkCodeViewTopSpace: viewModel.orientation == .landscape ? 40 : 56) {
                    
                    if viewModel.orientation == .landscape && authViewModel.showTextFieldWithKeyboard {
                        VStack(spacing: 0) {
                            
                            VStack{}.frame(height: 16)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(ColorsUi.APC_White)
                                    .stroke(!authViewModel.isMagicLinkCodeValid ? Color.red : .clear, lineWidth: 1)
                                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
                                
                                HStack(spacing: 0) {
                                    Text(Constants.emailLabel)
                                    
                                    VStack{}.frame(width: 8)
                                    
                                    FocusableTextField(authViewModel: authViewModel, placeholder: Constants.yourEmail, text: $authViewModel.magicLinkCode, shouldFocus: $shouldFocusTextField)
                                    
                                }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 32 : UIScreen.main.bounds.width - 48 - 32)
                            }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { shouldFocusTextField = true }
                        }
                    } else {
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
                            
                            VStack{}.frame(height: viewModel.orientation == .landscape ? 12 : 58)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(ColorsUi.APC_White)
                                    .stroke(!authViewModel.isMagicLinkCodeValid ? Color.red : .clear, lineWidth: 1)
                                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
                                
                                HStack(spacing: 0) {
                                    
                                    Text(Constants.codeLabel)
                                    
                                    VStack{}.frame(width: 8)
                                    
                                    if viewModel.orientation == .landscape {
                                        Text(Constants.codeLabel)
                                            .foregroundColor(ColorsUi.APC_Gray)
                                    } else {
                                        TextField(Constants.codeLabel, text: $authViewModel.magicLinkCode)
                                    }
                                }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 32 : UIScreen.main.bounds.width - 48 - 32, height: 44, alignment: .leading)
                            }
                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
                            .onTapGesture {
                                if viewModel.orientation == .landscape { withAnimation(.easeInOut(duration: 0.15)) { authViewModel.showTextFieldView() } }
                            }
                            
                            if !authViewModel.isMagicLinkCodeValid {
                                VStack(spacing: 0) {
                                    VStack{}.frame(height: 4)
                                    
                                    Text(Constants.incorrectCode)
                                        .font(FontsUi.APC_Footnote_Bold)
                                        .foregroundColor(Color.red)
                                        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 16, alignment: .leading)
                                }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 20)
                            } else {
                                VStack{}.frame(height: 20)
                            }
                            
                            VStack{}.frame(height: viewModel.orientation == .landscape ? 3 : 14)
                            
                        }
                    }
                }.onDisappear { authViewModel.hideTextFieldView() }
                
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        
                        VStack{}.frame(height: 21)
                        
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
                    }
                }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 51, alignment: .topTrailing)
                
                VStack(spacing: 0) {
                    
                    VStack{}.frame(height: 8)
                    
                    Button(action: {
                        authViewModel.loginWithMagicLink()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(transactionViewModel.transaction != nil ? ColorsUi.APC_Pink : ColorsUi.APC_Gray)
                            Text(Constants.continueText)
                        }
                    }
                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                    .foregroundColor(ColorsUi.APC_White)
                    
                    VStack{}.frame(height: buttonBottomSafeArea)
                    
                }.frame(maxHeight: .infinity, alignment: .bottom)
            }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, alignment: .center)
        }
    }
}
