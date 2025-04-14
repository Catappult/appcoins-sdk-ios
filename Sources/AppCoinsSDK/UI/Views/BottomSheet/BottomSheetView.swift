//
//  BottomSheetView.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI
import UIKit

internal struct BottomSheetView: View {
    
    @State private var isPresented = false
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    @State private var isSafeAreaPresented = false
    
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
                }
            })
            .onChange(of: viewModel.purchaseState) { newValue in isPresented = (newValue == .paying) }
    }
}

internal extension BottomSheetView {
    func toUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}
