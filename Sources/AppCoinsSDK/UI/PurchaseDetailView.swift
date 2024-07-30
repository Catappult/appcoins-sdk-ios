//
//  PurchaseDetailView.swift
//
//
//  Created by Graciano Caldeira on 30/07/2024.
//

import SwiftUI

struct PurchaseDetailView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var adyenController: AdyenController
    @Binding var dynamicHeight: CGFloat
    var startObservingDynamicHeight: () -> Void
    var stopObservingDynamicHeight: () -> Void
    
    //    var flavor: Flavor
        var height: CGFloat
    
    var body: some View {
        ZStack() {
            ColorsUi.APC_LightGray
            
            if viewModel.purchaseState == .paying {
                PaymentChoiceBottomSheet(viewModel: viewModel)
            }
        
            if viewModel.purchaseState == .adyen {
                if adyenController.state == .none {
                    AdyenLoadingBottomSheet(viewModel: viewModel)
                }
                
                if adyenController.state == .choosingCreditCard {
                    CreditCardChoiceBottomSheet(viewModel: viewModel)
                }
                
                if adyenController.state == .newCreditCard {
                    CreditCardBottomSheet(viewModel: viewModel, dynamicHeight: $dynamicHeight)
                        .onAppear{ startObservingDynamicHeight() }
                        .onDisappear{ stopObservingDynamicHeight() }
                        .frame(width: UIScreen.main.bounds.size.width, height: dynamicHeight)
                }
                
                if adyenController.state == .paypal {
                    EmptyView()
                }
            }
            
        }.frame(width: UIScreen.main.bounds.size.width, height: height )
            .cornerRadius(13, corners: [.topLeft, .topRight])
    }
}
