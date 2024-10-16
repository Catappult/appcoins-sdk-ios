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
                        
                        // Payment methods
                        HStack(spacing: 0) {
                            VStack(spacing: 0) {
                                RadioButtonGroupView(viewModel: viewModel)
                                    .onAppear(perform: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                            withAnimation(.easeInOut(duration: 30)) {
                                                scrollViewProxy.scrollTo("top", anchor: .top)
                                            }
                                        }
                                    })
                            }
                        }
                        
                        HStack {}.frame(height: !transactionViewModel.showOtherPaymentMethods ? 40 : 26)
                        
                    }.ignoresSafeArea(.all)
                }.defaultScrollAnchor(.bottom)
            }
        }
    }
}
