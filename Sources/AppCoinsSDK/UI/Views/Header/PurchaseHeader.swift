//
//  PurchaseHeader.swift
//
//
//  Created by aptoide on 02/01/2025.
//

import SwiftUI

internal struct PurchaseHeader<Content: View>: View {
        
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    internal let blurred: Bool
    internal let content: () -> Content
    
    internal init(blurred: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.blurred = blurred
        self.content = content
    }
    
    internal var body: some View {
        HStack(spacing: 0) {
            
            VStack{}.frame(width: 24)
            
            VStack(alignment: .leading, spacing: 0) {
                content()
            }.frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
            
            CloseButton(action: viewModel.dismiss)
            
            VStack{}.frame(width: 24)
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.width, height: 72)
        .background(blurred ? BlurView(style: .systemMaterial) : nil)
        .onTapGesture {
            UIApplication.shared.dismissKeyboard()
            if viewModel.isKeyboardVisible { AdyenController.shared.presentableComponent?.viewController.view.findAndResignFirstResponder() }
        }
    }
}
