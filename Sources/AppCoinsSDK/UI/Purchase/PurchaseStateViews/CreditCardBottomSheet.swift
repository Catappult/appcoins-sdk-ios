//
//  CreditCardBottomSheet.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import Foundation
import SwiftUI
import ActivityIndicatorView

internal struct CreditCardBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var transactionViewModel: TransactionViewModel
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    
    @Binding internal var dynamicHeight: CGFloat
    @Binding internal var isLandscape: Bool
    
    internal var body: some View {
       
        VStack(spacing: 0) {
            BottomSheetAppHeader(viewModel: viewModel, transactionViewModel: transactionViewModel)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .ignoresSafeArea(.all)
                    .onAppear(perform: {
                        print("PortraitAppHeader")
                    })
            
            if let viewController = adyenController.presentableComponent?.viewController {
                if viewModel.isLandscape {
                    ScrollView {
                        AdyenViewControllerWrapper(viewController: viewController, viewModel: viewModel)
                            .frame(height: dynamicHeight)
                        //                        .frame(maxHeight: .infinity, alignment: .top)
                    }.frame(width: UIScreen.main.bounds.width - 176 - 32, height: UIScreen.main.bounds.height * 0.9 - 72)
                } else {
                    AdyenViewControllerWrapper(viewController: viewController, viewModel: viewModel)
                        .frame(height: dynamicHeight) // dynamicHeight
                    //                        .frame(maxHeight: .infinity, alignment: .top)
                }
            } else {
                ZStack {
                    ActivityIndicatorView(
                        isVisible: .constant(true), type: .growingArc(ColorsUi.APC_Gray, lineWidth: 1.5))
                        .frame(width: 41, height: 41)
                    
                    Image("loading-appc-icon", bundle: Bundle.module)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 23)
                }.animation(.linear(duration: 1.5).repeatForever(autoreverses: false))
            }
        }.padding(.horizontal, 16)
    }
}
