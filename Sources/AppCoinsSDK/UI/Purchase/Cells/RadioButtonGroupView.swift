//
//  RadioButtonGroupView.swift
//
//
//  Created by aptoide on 09/03/2023.
//

import SwiftUI

internal struct RadioButtonGroupView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    internal var body: some View {
        
        if let options = transactionViewModel.transaction?.paymentMethods {
            VStack(spacing: 0) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        if (!option.disabled) {
                            transactionViewModel.selectPaymentMethod(paymentMethod: option)
                        }
                        if viewModel.canChooseMethod == true {
                            viewModel.setCanChooseMethod(canChooseMethod: false)
                        }
                        viewModel.setHasNewPaymentMethodSelected(hasNewPaymentMethodSelected: true)
                    }) {
                        ZStack {
                            ColorsUi.APC_White
                            HStack(spacing: 0) {
                                PaymentMethodIcon(icon: option.icon, disabled: option.disabled)
                                    .frame(width: 24, height: 24)
                                    .padding(.horizontal, 16)
                                
                                Text(option.label)
                                    .foregroundColor(option.disabled ? ColorsUi.APC_Gray : ColorsUi.APC_Black)
                                    .font(FontsUi.APC_Subheadline)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Image(systemName: "chevron.right")
                                    .font(FontsUi.APC_Footnote)
                                    .foregroundColor(ColorsUi.APC_ArrowBanner)
                                
                                VStack {}.frame(width: 16)
                                
                            }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 64)
                        }.frame(height: 50)
                    }.buttonStyle(flatButtonStyle())
                    
                    if (option.name != options.last?.name) {
                        Divider()
                            .background(ColorsUi.APC_LightGray)
                    }
                }
            }
            .background(ColorsUi.APC_White)
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48)
            .cornerRadius(10)
        }
    }
}
