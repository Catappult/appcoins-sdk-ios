//
//  PaymentMethodListBottomSheet.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 25/11/2024.
//

import SwiftUI


struct PaymentMethodListBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    
    var body: some View {
        if #available(iOS 16.4, *) {
            if viewModel.orientation == .landscape {
                PaymentMethodListView(viewModel: viewModel)
                    .presentationCompactAdaptation(.fullScreenCover)
                    .clipShape(RoundedCorner(radius: 13, corners: [.topLeft, .topRight]))
                    .presentationBackground {
                        Color.black.opacity(0.001)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            .onTapGesture {
                                viewModel.dismissPaymentMethodChoiceSheet()
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea(.all)
                
            } else {
                PaymentMethodListView(viewModel: viewModel)
                    .presentationDragIndicator(.hidden)
            }
        }
    }
}
