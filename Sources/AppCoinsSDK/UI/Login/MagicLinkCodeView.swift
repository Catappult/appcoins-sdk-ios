//
//  MagicLinkCodeView.swift
//
//
//  Created by Graciano Caldeira on 28/11/2024.
//

import SwiftUI

struct MagicLinkCodeView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    
    var body: some View {
        if #available(iOS 17, *) {
            ZStack(alignment: .top) {
                ScrollViewReader { scrollViewProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            
                            VStack {}.frame(height: 56)
                                .id("top")
                            
                            Image("magic-link-image", bundle: Bundle.APPCModule)
                                .resizable()
                                .frame(width: 105, height: 72)
                            
                            VStack {}.frame(height: 16)
                            
                            Text(Constants.checkYourEmail)
                                .font(FontsUi.APC_Title3_Bold)
                                .foregroundColor(ColorsUi.APC_Black)
                            
                            VStack {}.frame(height: 16)
                            
                            Text(Constants.sentCodeTo + ": " + viewModel.emailText)
                                .font(FontsUi.APC_Subheadline)
                                .foregroundColor(ColorsUi.APC_Black)
                                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 30 : UIScreen.main.bounds.width - 48 - 30)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                            
                            VStack {}.frame(height: 64)
                            
                            HStack(spacing: 0) {
                                VStack {}.frame(width: 16)
                                
                                Text(Constants.codeLabel)
                                
                                VStack {}.frame(width: 8)
                                
                                TextField(text: $viewModel.magicLinkCode) {
                                    Text(Constants.codeLabel)
                                }
                                
                                VStack {}.frame(width: 18)
                                    .id("bottom")
                                    .onAppear(perform: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                            withAnimation(.easeInOut(duration: 30)) {
                                                scrollViewProxy.scrollTo("top", anchor: .top)
                                            }
                                        }
                                    })
                            }
                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 44)
                            .background(ColorsUi.APC_White)
                            .cornerRadius(10)
                            
                            if viewModel.orientation == .landscape { VStack {}.frame(height: viewModel.isKeyboardVisible ? 140 : 0) }
                            
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }.defaultScrollAnchor(.bottom)
                }
                
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        
                        VStack {}.frame(height: 21)
                        
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
                }
                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 56, alignment: .topTrailing)
            }
        }
    }
}
