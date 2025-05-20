//
//  PurchaseBottomSheet.swift
//
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI
import UIKit
@_implementationOnly import WebKit

internal struct PurchaseBottomSheet: View {
    
    @ObservedObject internal var viewModel: PurchaseViewModel = PurchaseViewModel.shared
    @Environment(\.colorScheme) var colorScheme
    
    internal var body: some View {
        BottomSheetPresenter(isPresented: $viewModel.isWebviewWebCheckoutPresented)
            .ignoresSafeArea(edges: .bottom)
        
        if viewModel.isBrowserWebCheckoutPresented {
            ZStack {
                Color.black.opacity(0.7)
                
                VStack {
                    VStack {
                        ProgressView()
                    }
                    .frame(maxHeight: .infinity)
                    
                    Button {
                        viewModel.dismiss()
                    } label: {
                        Text(Constants.cancelButton)
                            .frame(maxWidth: .infinity)
                    }
                    
                    HStack{}.frame(height: Utils.bottomSafeAreaHeight)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        }
    }
}

internal extension PurchaseBottomSheet {
    func toUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}
