//
//  PaymentMethodListView.swift
//  
//
//  Created by Graciano Caldeira on 10/12/2024.
//

import SwiftUI

internal struct PaymentMethodListView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    
    internal var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(Constants.chooseYourPaymentMethod)
                    .font(FontsUi.APC_Callout_Bold)
                    .foregroundColor(ColorsUi.APC_Black)
                    .frame(width: 230, height: 21)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                CloseButton(action: viewModel.dismissPaymentMethodChoiceSheet)
            }
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 72)
            
            VStack{}.frame(height: 8)
            
            // Payment methods
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    PaymentMethodList(viewModel: viewModel)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.width, height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : .infinity)
        .background(ColorsUi.APC_BottomSheet_LightGray_Background)
        .ignoresSafeArea(.all)
    }
}
