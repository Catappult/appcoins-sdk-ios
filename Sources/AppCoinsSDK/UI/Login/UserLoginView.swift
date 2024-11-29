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
        VStack(spacing: 0) {
            Button {
                print("")
            } label: {
                ZStack(alignment: .leading) {
                    if #available(iOS 17, *) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(ColorsUi.APC_White)
                            .stroke(ColorsUi.APC_Black, lineWidth: 1)
                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                    }
                    
                    HStack(spacing: 0) {
                        Image("facebook-logo", bundle: Bundle.APPCModule)
                            .resizable()
                            .frame(width: 8, height: 15)
                        
                        VStack {}.frame(width: 8)
                        
                        Text(Constants.signInWithFacebookText)
                            .font(FontsUi.APC_Body)
                    }
                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                }
            }.buttonStyle(flatButtonStyle())
            
            VStack {}.frame(height: 14)
            
            Button {
                print("")
            } label: {
                ZStack(alignment: .leading) {
                    if #available(iOS 17, *) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(ColorsUi.APC_White)
                            .stroke(ColorsUi.APC_Black, lineWidth: 1)
                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
                    }
                    
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
            
            VStack {}.frame(height: 24)
            
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
            
            VStack {}.frame(height: 24)
            
            HStack(spacing: 0) {
                VStack {}.frame(width: 16)
                
                Text(Constants.emailLabel)
                
                VStack {}.frame(width: 8)
                
                if #available(iOS 15, *) {
                    TextField(text: $viewModel.emailText) {
                        Text(Constants.yourEmail)
                    }
                }
                
                VStack {}.frame(width: 16)
            }
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
            .background(ColorsUi.APC_White)
            .cornerRadius(10)
            
            VStack {}.frame(height: 24)
            
        }.onDisappear(perform: {
            viewModel.setCanLogin(canLogin: false)
        })
    }
}
