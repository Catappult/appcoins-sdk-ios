//
//  PaymentChoiceBottomSheet.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 25/11/2024.
//

import SwiftUI

struct PaymentChoiceBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack(spacing: 0) {
                
                Text(Constants.chooseYourPaymentMethod)
                    .font(FontsUi.APC_Callout_Bold)
                    .foregroundColor(ColorsUi.APC_Black)
                    .frame(width: 230, height: 21)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    viewModel.setCanChooseMethod(canChooseMethod: false)
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
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 72)
                
            VStack {}.frame(height: 8)
            
            // Payment methods
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    PaymentMethodList(viewModel: viewModel)
                        .animation(.easeInOut(duration: 0.2))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorsUi.APC_BottomSheet_LightGray_Background)
        .ignoresSafeArea(.all)
    }
}
