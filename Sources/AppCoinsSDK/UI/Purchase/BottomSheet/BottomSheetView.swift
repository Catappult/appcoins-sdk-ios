//
//  BottomSheetView.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI
import UIKit

struct BottomSheetView: View {
    
    @ObservedObject var viewModel : BottomSheetViewModel

    @State private var isPresented = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3).onTapGesture { if viewModel.purchaseState != .processing { viewModel.dismiss() } }

            VStack {
                VStack{ }.frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if viewModel.purchaseState == .paying {
                    PurchaseBottomSheet(viewModel: viewModel)
                        .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
                        .transition(.move(edge: .bottom))
                }
                
                if viewModel.purchaseState == .processing {
                    ProcessingBottomSheet(viewModel: viewModel)
                        .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
                        .transition(.move(edge: .bottom))
                }
            
                if viewModel.purchaseState == .success {
                    SuccessBottomSheet(viewModel: viewModel)
                }
                
                if viewModel.purchaseState == .failed {
                    ErrorBottomSheet(viewModel: viewModel)
                }
                
                if viewModel.purchaseState == .nointernet {
                    NoInternetBottomSheet(viewModel: viewModel)
                }
                
            }
            .onAppear { withAnimation { isPresented = true } }
            .onDisappear { withAnimation { isPresented = false } }
        }.ignoresSafeArea()
    }
}

extension BottomSheetView {
    func toUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}
