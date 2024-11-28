//
//  SelectedPaymentMethodView.swift
//
//
//  Created by Graciano Caldeira on 04/10/2024.
//

import SwiftUI

struct SelectedPaymentMethodView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var paypalViewModel: PayPalDirectViewModel = PayPalDirectViewModel.shared
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
                        
                        HStack(spacing: 0) {
                            VStack(spacing: 0) {
                                if viewModel.hasNewPaymentMethodSelected, let paymentMethodSelected = transactionViewModel.paymentMethodSelected {
                                    VStack(spacing:0) {
                                        HStack(spacing: 0) {
                                            PaymentMethodIcon(icon: paymentMethodSelected.icon, disabled: false)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .frame(width: 24, height: 24)
                                            
                                            VStack {}.frame(width: 16)
                                            
                                            Text(paymentMethodSelected.label)
                                                .font(FontsUi.APC_Body)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 32 : UIScreen.main.bounds.width - 48 - 32, height: 64)
                                    }
                                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 64)
                                    .background(ColorsUi.APC_White)
                                    .cornerRadius(10)
                                    .onDisappear { if viewModel.hasNewPaymentMethodSelected { viewModel.setHasNewPaymentMethodSelected(hasNewPaymentMethodSelected: false) } }
                                    
                                } else {
                                    // Last payment method
                                    ZStack {
                                        ColorsUi.APC_White
                                        
                                        HStack(spacing: 0) {
                                            VStack(spacing: 0) {
                                                if let icon = URL(string: transactionViewModel.lastPaymentMethod?.icon ?? "") {
                                                    PaymentMethodQuickIcon(icon: icon)
                                                }
                                            }
                                            
                                            VStack {}.frame(width: 16)
                                            
                                            VStack(spacing: 0) {
                                                if transactionViewModel.lastPaymentMethod?.name == Method.appc.rawValue {
                                                    Text(transactionViewModel.lastPaymentMethod?.label)
                                                        .foregroundColor(ColorsUi.APC_Black)
                                                        .font(FontsUi.APC_Callout)
                                                        .lineLimit(1)
                                                        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 168 : UIScreen.main.bounds.width - 48 - 168, alignment: .leading)
                                                    
                                                    VStack {}.frame(height: 4)
                                                    
                                                    Text(Constants.earnedEnoughAppcText)
                                                        .foregroundColor(ColorsUi.APC_Gray)
                                                        .font(FontsUi.APC_Caption1)
                                                        .lineLimit(2)
                                                        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 168 : UIScreen.main.bounds.width - 48 - 168, alignment: .leading)
                                                    
                                                } else {
                                                    Text(transactionViewModel.lastPaymentMethod?.label)
                                                        .foregroundColor(ColorsUi.APC_Black)
                                                        .font(FontsUi.APC_Callout)
                                                        .lineLimit(1)
                                                        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 168 : UIScreen.main.bounds.width - 48 - 168, alignment: .leading)
                                                }
                                            }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 168 : UIScreen.main.bounds.width - 48 - 96, alignment: .leading)
                                            
                                            if transactionViewModel.paypalLogOut {
                                                Button(action: paypalViewModel.logoutPayPal) {
                                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                                        .foregroundColor(ColorsUi.APC_ArrowBanner)
                                                    
                                                }.frame(maxHeight: .infinity, alignment: .trailing)
                                            }
                                        }
                                    }
                                    .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 64)
                                    .cornerRadius(13)
                                }
                                
                                VStack {}.frame(height: 8)
                                
                                Button {
                                    viewModel.setCanChooseMethod(canChooseMethod: true)
                                } label: {
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack(spacing: 0) {
                                            Text(viewModel.hasNewPaymentMethodSelected ? Constants.otherPaymentMethodsText : Constants.selectPaymentMethodText)
                                                .font(FontsUi.APC_Body)
                                                .frame(width: 200, alignment: .leading)
                                            
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
                                        Text(Constants.signToGetBonusText)
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
                                .onAppear(perform: {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                        withAnimation(.easeInOut(duration: 30)) {
                                            scrollViewProxy.scrollTo("top", anchor: .top)
                                        }
                                    }
                                })
                            }
                        }
                        
                        HStack {}.frame(height: 40)
                        
                    }.ignoresSafeArea(.all)
                }.defaultScrollAnchor(.bottom)
            }
        }
    }
}
