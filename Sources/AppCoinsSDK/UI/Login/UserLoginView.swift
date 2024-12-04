//
//  UserLoginView.swift
//
//
//  Created by Graciano Caldeira on 28/11/2024.
//

import SwiftUI

struct UserLoginView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    
    var body: some View {
        if #available(iOS 17, *) {
            ScrollViewReader { scrollViewProxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        VStack {}.frame(height: 72 + 8)
                            .id("top")
                        
                        VStack {}.frame(height: 24)
                        
                        Button {} label: {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(ColorsUi.APC_White)
                                    .stroke(ColorsUi.APC_Black, lineWidth: 1)
                                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                                
                                HStack(spacing: 0) {
                                    Image("google-logo", bundle: Bundle.APPCModule)
                                        .resizable()
                                        .frame(width: 13, height: 13)
                                    
                                    VStack {}.frame(width: 8)
                                    
                                    Text(Constants.signInWithGoogleText)
                                        .font(FontsUi.APC_Body)
                                }
                                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                            }
                        }.buttonStyle(flatButtonStyle())
                        
                        VStack {}.frame(height: 38)
                        
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
                        }
                        .frame(height: 16)
                        
                        VStack {}.frame(height: 40)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(ColorsUi.APC_White)
                                .stroke(viewModel.isValidLoginEmail ? .clear : Color.red, lineWidth: 1)
                                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
                            
                            HStack(spacing: 0) {
                                Text(Constants.emailLabel)
                                
                                VStack {}.frame(width: 8)
                                
                                TextField(text: $viewModel.loginEmailText) {
                                    Text(Constants.yourEmail)
                                }
                            }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 32 : UIScreen.main.bounds.width - 48 - 32)
                        } .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
                        
                        if !viewModel.isValidLoginEmail {
                            VStack(spacing: 0) {
                                VStack{}.frame(height: 4)
                                
                                Text(Constants.invalidEmail)
                                    .font(FontsUi.APC_Footnote_Bold)
                                    .foregroundColor(Color.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48)
                        } else {
                            VStack {}.frame(width: 16)
                        }
                        
                        if viewModel.orientation == .landscape { VStack {}.frame(height: viewModel.isKeyboardVisible ? 120 : 0) }
                        
                        VStack {}.frame(height: 24)
                            .id("bottom")
                            .onAppear(perform: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    withAnimation(.easeInOut(duration: 30)) {
                                        scrollViewProxy.scrollTo("top", anchor: .top)
                                    }
                                }
                            })
                    }
                }.defaultScrollAnchor(.bottom)
            }
        }
    }
}
