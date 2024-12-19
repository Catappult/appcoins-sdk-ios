//
//  LoginView.swift
//
//
//  Created by Graciano Caldeira on 28/11/2024.
//

import SwiftUI


struct LoginView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var authViewModel: AuthViewModel
    @ObservedObject internal var transactionViewModel: TransactionViewModel
    
    internal let portraitBottomSheetHeight: CGFloat
    internal let buttonHeightPlusTopSpace: CGFloat
    internal let bottomSheetHeaderHeight: CGFloat
    internal let buttonBottomSafeArea: CGFloat
    
//    @State private var shouldFocusTextField: Bool = false
    
    var body: some View {
        if #available(iOS 17, *) {
            PurchaseViewWrapper(height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : portraitBottomSheetHeight, buttonHeightPlusTopSpace: buttonHeightPlusTopSpace, bottomSheetHeaderHeight: bottomSheetHeaderHeight, buttonBottomSafeArea: buttonBottomSafeArea) {
                
                if viewModel.orientation == .landscape && authViewModel.showTextFieldWithKeyboard {
                    VStack(spacing: 0) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(ColorsUi.APC_White)
                                .stroke(!authViewModel.isMagicLinkEmailValid ? Color.red : .clear, lineWidth: 1)
                                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
                            
                            HStack(spacing: 0) {
                                Text(Constants.emailLabel)
                                
                                VStack{}.frame(width: 8)
                                
                                FocusableTextField(authViewModel: authViewModel, placeholder: Constants.yourEmail, text: $authViewModel.magicLinkEmail)
                                
                            }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 32 : UIScreen.main.bounds.width - 48 - 32)
                        }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
                        
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { authViewModel.setFocusTextField(shouldFocusTextField: true) }
                    }
                } else {
                    VStack(spacing: 0) {
                        
                        VStack{}.frame(height: viewModel.orientation != .landscape ? 32 : 0)
                        
                        Button(action: { authViewModel.loginWithGoogle() }) {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(ColorsUi.APC_White)
                                    .stroke(ColorsUi.APC_Black, lineWidth: 1)
                                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                                
                                HStack(spacing: 0) {
                                    Image("google-logo", bundle: Bundle.APPCModule)
                                        .resizable()
                                        .frame(width: 13, height: 13)
                                    
                                    VStack{}.frame(width: 8)
                                    
                                    Text(Constants.signInWithGoogleText)
                                        .font(FontsUi.APC_Body)
                                }
                                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                            }
                        }
                        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                        .buttonStyle(flatButtonStyle())
                        
                        VStack{}.frame(height: 36)
                        
                        HStack(spacing: 0) {
                            Rectangle()
                                .frame(width: viewModel.orientation == .landscape ? 222 : 106, height: 1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(ColorsUi.APC_DarkGray)
                            
                            Text(Constants.orContinueWith)
                                .font(FontsUi.APC_Caption1)
                                .foregroundColor(ColorsUi.APC_DarkGray)
                            
                            Rectangle()
                                .frame(width: viewModel.orientation == .landscape ? 222 : 106, height: 1)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundColor(ColorsUi.APC_DarkGray)
                        }.frame(height: 16)
                        
                        VStack{}.frame(height: 16)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(ColorsUi.APC_White)
                                .stroke(!authViewModel.isMagicLinkEmailValid ? Color.red : .clear, lineWidth: 1)
                                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
                            
                            HStack(spacing: 0) {
                                
                                Text(Constants.emailLabel)
                                
                                VStack{}.frame(width: 8)
                                
                                if viewModel.orientation == .landscape {
                                    TextField(Constants.yourEmail, text: $authViewModel.magicLinkEmail)
                                } else {
                                    TextField(Constants.yourEmail, text: $authViewModel.magicLinkEmail)
                                }
                            }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 32 : UIScreen.main.bounds.width - 48 - 32, alignment: .leading)
                        }
                        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
                        .onTapGesture {
                            if viewModel.orientation == .landscape {
                                withAnimation(.easeInOut(duration: 0.4)) { authViewModel.showTextFieldView() }
                            }
                        }
                        
                        if !authViewModel.isMagicLinkEmailValid {
                            VStack(spacing: 0) {
                                VStack{}.frame(height: 4)
                                
                                Text(Constants.invalidEmail)
                                    .font(FontsUi.APC_Footnote_Bold)
                                    .foregroundColor(Color.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 20)
                        } else {
                            VStack{}.frame(height: 20)
                        }
                    }
                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48)
                }
            }
            .onDisappear { authViewModel.hideTextFieldView() }
            
            VStack{}.frame(height: 8)
            
            Button(action: {
                if authViewModel.validateEmail() { authViewModel.sendMagicLink() }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(transactionViewModel.transaction != nil ? ColorsUi.APC_Pink : ColorsUi.APC_Gray)
                    Text(Constants.continueText)
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
            .foregroundColor(ColorsUi.APC_White)
            
            VStack{}.frame(height: buttonBottomSafeArea)
            
        }
    }
}
