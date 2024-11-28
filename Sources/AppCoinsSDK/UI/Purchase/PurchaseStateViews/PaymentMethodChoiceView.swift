//
//  PaymentMethodChoiceView.swift
//
//
//  Created by Graciano Caldeira on 04/10/2024.
//

import SwiftUI

struct PaymentMethodChoiceView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    var body: some View {
        if #available(iOS 17, *) {
            ScrollViewReader { scrollViewProxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        VStack {}.frame(height: 72)
                            .id("top")
                            .onAppear(perform: {
                                scrollViewProxy.scrollTo("bottom", anchor: .bottom)
                            })
                        
                        VStack {}.frame(height: 8)
                        
                        PurchaseBonusBanner(viewModel: viewModel, transactionViewModel: transactionViewModel)
                        
                        VStack {}.frame(height: 16)
                        
                        Button {
                            viewModel.setCanChooseMethod(canChooseMethod: true)
                        } label: {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(spacing: 0) {
                                    Text(Constants.selectPaymentMethodTitle)
                                        .font(FontsUi.APC_Body)
                                        .frame(width: 183, alignment: .leading)
                                    
                                    Image(systemName: "chevron.right")
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .frame(height: 40)
                                        .foregroundColor(ColorsUi.APC_ArrowBanner)
                                }
                                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 32 - 48 : UIScreen.main.bounds.width - 32 - 48, height: 40)
                            }
                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 40)
                            .background(ColorsUi.APC_White)
                            .cornerRadius(10)
                        }
                        .buttonStyle(flatButtonStyle())
                        
                        VStack {}.frame(height: 8)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 0) {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(ColorsUi.APC_LoginIcon)
                                
                                VStack {}.frame(width: 8)
                                
                                Text(Constants.signToGetBonusTitle)
                                    .font(FontsUi.APC_Body)
                                    .frame(width: 200, alignment: .leading)
                                
                                Image(systemName: "chevron.right")
                                    .font(FontsUi.APC_Footnote)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .foregroundColor(ColorsUi.APC_ArrowBanner)
                                
                            }
                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 32 - 48 : UIScreen.main.bounds.width - 32 - 48, height: 40)
                        }
                        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 40)
                        .background(ColorsUi.APC_White)
                        .cornerRadius(10)
                        
                        HStack {}.frame(height: 110)
                            .onAppear(perform: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    withAnimation(.easeInOut(duration: 30)) {
                                        scrollViewProxy.scrollTo("top", anchor: .top)
                                    }
                                }
                            })
                    }.ignoresSafeArea(.all)
                }.defaultScrollAnchor(.bottom)
            }
        }
    }
}
