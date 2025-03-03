//
//  BottomSheetView.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI
import UIKit
import WebKit

internal struct BottomSheetView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var isPresented = false
    
    internal var body: some View {
        HStack(spacing: 0) {}
            .sheet(isPresented: $isPresented, onDismiss: viewModel.dismiss, content: {
                if #available(iOS 17.4, *) {
                    VStack(spacing: 0) {
                        VStack{}.frame(height: 20)
                        
                        WebBottomSheetView()
                            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 116: UIScreen.main.bounds.width)
                            .presentationCompactAdaptation(.sheet)
                            .presentationDetents([viewModel.orientation == .landscape ? .fraction(0.9) : .fraction(0.6)])
                            
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(self.colorScheme == .dark ? ColorsUi.APC_WebViewDarkMode : ColorsUi.APC_WebViewLightMode)
                }
            })
            .onChange(of: viewModel.purchaseState) { newValue in isPresented = (newValue == .paying) }
    }
}
