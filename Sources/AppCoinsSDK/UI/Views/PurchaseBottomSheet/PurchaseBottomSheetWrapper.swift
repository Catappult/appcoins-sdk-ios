//
//  PurchaseBottomSheetWrapper.swift
//  
//
//  Created by aptoide on 02/01/2025.
//

import SwiftUI
@_implementationOnly import SkeletonUI
@_implementationOnly import ActivityIndicatorView

internal struct PurchaseBottomSheetWrapper<Header: View, Body: View>: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    
    @State private var isPresented = false
    
    @ObservedObject private var keyboardObserver = KeyboardObserver.shared
    
    @Binding internal var dynamicHeight: CGFloat
    
    internal let header: () -> Header
    internal let content: () -> Body
    
    internal let portraitBottomSheetHeight: CGFloat = 420
    internal var height: CGFloat {
        if viewModel.orientation == .landscape {
            return UIScreen.main.bounds.height * 0.9
        } else {
            if viewModel.purchaseState == .adyen && adyenController.state == .newCreditCard {
                return dynamicHeight + 72
            } else if viewModel.purchaseState == .login && keyboardObserver.isKeyboardVisible {
                return self.setHeightFromKeyboardToTop(keyboardObserverHeight: keyboardObserver.heighFromKeyboardToTop)
            } else {
                return portraitBottomSheetHeight
            }
        }
    }
    
    internal init(
        dynamicHeight: Binding<CGFloat>,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Body
    ) {
        self._dynamicHeight = dynamicHeight
        self.header = header
        self.content = content
    }
    
    internal var body: some View {
        ZStack(alignment: .top) {
            self.content()
                .frame(height: height)
            
            self.header()
                .frame(height: 72)
        }
        .frame(
            width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width,
            height: height,
            alignment: .center)
        .padding(.bottom, keyboardObserver.isKeyboardVisible && viewModel.orientation != .landscape && !viewModel.isManageAccountSheetPresented ? keyboardObserver.keyboardHeight: 0)
        .background(ColorsUi.APC_BottomSheet_LightGray_Background)
        .cornerRadius(13, corners: [.topLeft, .topRight])
        .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
        .transition(.move(edge: isPresented ? .bottom : .top))
        .onAppear { withAnimation(.easeIn) { isPresented = true } }
    }
    
    private func setHeightFromKeyboardToTop(keyboardObserverHeight: CGFloat) -> CGFloat {
        if keyboardObserverHeight > portraitBottomSheetHeight {
            return portraitBottomSheetHeight
        } else {
            return keyboardObserverHeight
        }
    }
}
