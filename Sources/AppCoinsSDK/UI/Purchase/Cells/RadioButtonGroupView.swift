//
//  RadioButtonGroupView.swift
//  
//
//  Created by aptoide on 09/03/2023.
//

import SwiftUI
import URLImage

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
                                    
                                if (transactionViewModel.paymentMethodSelected?.name == option.name) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .edgesIgnoringSafeArea(.all)
                                        .foregroundColor(ColorsUi.APC_Pink)
                                        .frame(width: 22, height: 22, alignment: .trailing)
                                        .padding(.trailing, 16)
                                } else {
                                    Circle()
                                        .strokeBorder(ColorsUi.APC_LightGray, lineWidth: 2)
                                        .frame(width: 22, height: 22, alignment: .trailing)
                                        .padding(.trailing, 16)
                                }
                                                            
                                
                            }.frame(width: UIScreen.main.bounds.width - 64)
                        }.frame(height: 44)
                    }.buttonStyle(flatButtonStyle())
                
                    if (option.name != options.last?.name) {
                        Divider()
                            .background(ColorsUi.APC_LightGray)
                    }
                        
                }
            }.background(ColorsUi.APC_White)
                .frame(width: UIScreen.main.bounds.width - 64)
                .cornerRadius(13)
        }
        
    }
    
}
