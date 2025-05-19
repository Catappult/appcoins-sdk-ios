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
        HStack(spacing: 0) {}
            .sheet(isPresented: $viewModel.isWebviewWebCheckoutPresented, onDismiss: viewModel.dismiss, content: {
                if #available(iOS 17.4, *) {
                    VStack(spacing: 0) {
                        VStack{}.frame(height: 20)
                        
                        WebCheckoutView()
                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 116: UIScreen.main.bounds.width)
                            .presentationCompactAdaptation(.sheet)
                            .presentationDetents([viewModel.orientation == .landscape ? .fraction(0.9) : .fraction(0.6)])
                        
                    }
                }
            })
        
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
