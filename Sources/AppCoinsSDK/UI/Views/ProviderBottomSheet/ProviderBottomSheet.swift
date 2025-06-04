//
//  ProviderBottomSheet.swift
//
//
//  Created by aptoide on 02/05/2025.
//

import Foundation
import SwiftUI
import UIKit
@_implementationOnly import WebKit

internal struct ProviderBottomSheet: View {
    
    @ObservedObject internal var viewModel: ProviderViewModel = ProviderViewModel.shared
    @Environment(\.colorScheme) var colorScheme
    
    internal var body: some View {
        SDKBottomSheet(
            content: {
                VStack(spacing: 0) {
                    PurchaseHeader()
                    
                    VStack(spacing: 0) {
                        AptoideProviderButton()
                        
                        HStack{}.frame(height: 8)
                        
                        AppleProviderButton()
                        
                        HStack{}.frame(height: 8)
                    }
                    
                    HStack{}.frame(height: Utils.bottomSafeAreaHeight)
                }
            },
            dismiss: viewModel.dismiss,
            background: self.colorScheme == .dark ? ColorsUi.APC_WebViewDarkMode : ColorsUi.APC_WebViewLightMode,
            width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 116: UIScreen.main.bounds.width,
            height: 184 + Utils.bottomSafeAreaHeight
        )
    }
}

internal extension ProviderBottomSheet {
    func toUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}
