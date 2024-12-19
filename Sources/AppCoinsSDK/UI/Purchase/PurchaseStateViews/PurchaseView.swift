//
//  PurchaseView.swift
//
//
//  Created by Graciano Caldeira on 04/10/2024.
//

import SwiftUI

struct PurchaseView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    internal let portraitBottomSheetHeight: CGFloat
    internal let buttonHeightPlusTopSpace: CGFloat
    internal let bottomSheetHeaderHeight: CGFloat
    internal let buttonBottomSafeArea: CGFloat
    
    var body: some View {
        if #available(iOS 17, *) {
            PurchaseViewWrapper(height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : portraitBottomSheetHeight, buttonHeightPlusTopSpace: self.buttonHeightPlusTopSpace, bottomSheetHeaderHeight: self.bottomSheetHeaderHeight,  buttonBottomSafeArea: self.buttonBottomSafeArea) {
                VStack(spacing: 0) {
                    
                    PurchaseBonusBanner(viewModel: viewModel, transactionViewModel: transactionViewModel, authViewModel: authViewModel)
                    
                    VStack{}.frame(height: 16)
                    
                    if let paymentMethodSelected = transactionViewModel.paymentMethodSelected {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                PaymentMethodIcon(icon: paymentMethodSelected.icon, disabled: false)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(width: 24, height: 24)
                                
                                VStack{}.frame(width: 16)
                                
                                Text(paymentMethodSelected.label)
                                    .font(FontsUi.APC_Body)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 32 : UIScreen.main.bounds.width - 48 - 32, height: 64)
                        }
                        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 64)
                        .background(ColorsUi.APC_White)
                        .cornerRadius(10)
                        
                        VStack{}.frame(height: 8)
                    }
                    
                    Button {
                        viewModel.presentPaymentMethodChoiceSheet()
                    } label: {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 0) {
                                Text(Constants.selectPaymentMethodText)
                                    .font(FontsUi.APC_Body)
                                    .frame(width: 183, alignment: .leading)
                                
                                Image(systemName: "chevron.right")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .frame(height: 40)
                                    .foregroundColor(ColorsUi.APC_SelectionArrow)
                            }
                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 32 - 48 : UIScreen.main.bounds.width - 32 - 48, height: 40)
                        }
                        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 40)
                        .background(ColorsUi.APC_White)
                        .cornerRadius(10)
                    }
                    .buttonStyle(flatButtonStyle())
                    
                    if !authViewModel.isLoggedIn {
                        VStack{}.frame(height: 8)
                        
                        Button {
                            viewModel.setPurchaseState(newState: .login)
                        } label: {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(spacing: 0) {
                                    Text(Constants.signToGetBonusText)
                                        .font(FontsUi.APC_Body)
                                        .frame(width: 200, alignment: .leading)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(FontsUi.APC_Footnote)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .foregroundColor(ColorsUi.APC_SelectionArrow)
                                    
                                }
                                .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 32 - 48 : UIScreen.main.bounds.width - 32 - 48, height: 40)
                            }
                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 40)
                            .background(ColorsUi.APC_White)
                            .cornerRadius(10)
                        }.buttonStyle(flatButtonStyle())
                    }
                }.ignoresSafeArea(.all)
            }
        }
    }
}
