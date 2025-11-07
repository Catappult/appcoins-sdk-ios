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
        switch viewModel.webCheckoutType {
        case .webview:
            if #available(iOS 14, *) {
                SDKBottomSheet(
                    content: {
                        VStack(spacing: 0) {
                            VStack{}.frame(height: 20)
                            WebCheckoutView()
                        }
                    },
                    dismiss: viewModel.dismiss,
                    background: self.colorScheme == .dark ? ColorsUi.APC_WebViewDarkMode : ColorsUi.APC_WebViewLightMode,
                    width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 116 : UIScreen.main.bounds.width,
                    height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : UIScreen.main.bounds.height * 0.75
                )
            }
        case .browser:
            if #available(iOS 14, *) { WebCheckoutLoading() }
        case .none:
            EmptyView()
        }
    }
}

internal extension PurchaseBottomSheet {
    func toUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}
