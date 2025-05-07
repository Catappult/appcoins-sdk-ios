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
            .sheet(isPresented: $viewModel.hasActivePurchase, onDismiss: viewModel.dismiss, content: {
                if #available(iOS 17.4, *) {
                    VStack(spacing: 0) {
                        VStack{}.frame(height: 20)
                        
                        WebCheckoutView()
                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 116: UIScreen.main.bounds.width)
                            .presentationCompactAdaptation(.sheet)
                            .presentationDetents([viewModel.orientation == .landscape ? .fraction(0.9) : .fraction(0.6)])
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(self.colorScheme == .dark ? ColorsUi.APC_WebViewDarkMode : ColorsUi.APC_WebViewLightMode)
                }
            })
    }
}

internal extension PurchaseBottomSheet {
    func toUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}
