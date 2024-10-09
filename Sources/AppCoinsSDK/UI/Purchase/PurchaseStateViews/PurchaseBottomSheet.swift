//
//  PurchaseBottomSheet.swift
//
//
//  Created by aptoide on 31/08/2023.
//

import Foundation
import SwiftUI
import URLImage
import SkeletonUI
import ActivityIndicatorView

internal struct PurchaseBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    @ObservedObject internal var paypalViewModel: PayPalDirectViewModel = PayPalDirectViewModel.shared
    
    @State private var isPresented = false
    
    @State private var transitionEdge: Edge = .bottom
    @State private var previousBackgroundHeight: CGFloat = 0
    @State private var timer: Timer? = nil
    @State private var dynamicHeight: CGFloat = 420
    @State private var dynamicPadding: CGFloat = 0
    @ObservedObject private var keyboardObserver = KeyboardObserver.shared
    
    internal var body: some View {
        
        VStack(spacing: 0) {
            if viewModel.purchaseState == .paying {
                if viewModel.isLandscape {
                    ZStack(alignment: .top) {
                        VStack(spacing: 0) {
                            
                            if transactionViewModel.lastPaymentMethod != nil || transactionViewModel.showOtherPaymentMethods {
                                if (!transactionViewModel.showOtherPaymentMethods) {
                                    LandscapeLastPaymentMethod(viewModel: viewModel)
                                } else {
                                    LandscapePaymentMethodChoice(viewModel: viewModel)
                                }
                            }
                            
                            VStack {}.frame(height: 8)
                            
                            // Buying button
                            Button(action: {
                                DispatchQueue.main.async { viewModel.purchaseState = .processing }
                                viewModel.buy()
                            }) {
                                ZStack {
                                    
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(transactionViewModel.transaction != nil ? ColorsUi.APC_Pink : ColorsUi.APC_Gray)
                                    Text(Constants.buyText)
                                }
                            }
                            .disabled(transactionViewModel.transaction == nil)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .frame(width: UIScreen.main.bounds.width - 176 - 320, height: 50)
                            .foregroundColor(ColorsUi.APC_White)
                            
                            VStack {}.frame(height: Utils.bottomSafeAreaHeight == 0 ? 5 : Utils.bottomSafeAreaHeight)
                                .background(Color.red)
                            
                        }.frame(maxHeight: .infinity, alignment: .bottom)
                        
                        BottomSheetAppHeader(viewModel: viewModel, transactionViewModel: transactionViewModel)
                        
                    }
                } else {
                    PortraitPaymentChoice(viewModel: viewModel)
                }
            }
            
            if viewModel.purchaseState == .adyen {
                if adyenController.state == .none {
                    AdyenLoadingBottomSheet(viewModel: viewModel)
                }
                
                if adyenController.state == .choosingCreditCard {
                    CreditCardChoiceBottomSheet(viewModel: viewModel)
                }
                
                if adyenController.state == .newCreditCard {
                    CreditCardBottomSheet(viewModel: viewModel, transactionViewModel: transactionViewModel, dynamicHeight: $dynamicHeight)
                }
                
                if adyenController.state == .paypal {
                    EmptyView()
                }
            }
            
        }
        .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width, height: viewModel.isLandscape ? UIScreen.main.bounds.height * 0.9 : 420)
        .padding(.bottom, keyboardObserver.isKeyboardVisible && !viewModel.isLandscape ? keyboardObserver.keyboardHeight /*- dynamicPadding */: 0)
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
        .cornerRadius(13, corners: [.topLeft, .topRight])
        .modifier(MeasureBottomPositionModifier(onChange: { newValue in
            let difference = UIScreen.main.bounds.height - newValue
//            dynamicPadding = difference
        }))        // Otherwise (with a regular general animation) the skeletons animation does not work
        .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
        .transition(.move(edge: isPresented ? .bottom : .top))
        .onAppear { withAnimation { isPresented = true } }
    }
    
    internal struct MeasureBottomPositionModifier: ViewModifier {
        internal var onChange: (CGFloat) -> Void
        
        // Use a State variable to store the latest preference value
        @State private var debouncedValue: CGFloat = 0
        
        // Use a Timer to trigger updates at a fixed interval
        // This timer will prevent the UI from updating more than once per frame which causes some unexpected problems
        private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
        
        internal func body(content: Content) -> some View {
            content
                .background(GeometryReader { proxy in
                    Color.clear
                        .preference(key: BottomPositionPreferenceKey.self, value: proxy.frame(in: .global).maxY)
                })
                .onReceive(timer) { _ in
                    // Use the latest value stored in the @State variable
                    self.onChange(self.debouncedValue)
                }
                .onPreferenceChange(BottomPositionPreferenceKey.self) { newValue in
                    // Store the new preference value in the @State variable
                    self.debouncedValue = newValue
                }
        }
    }
    
    internal struct BottomPositionPreferenceKey: PreferenceKey {
        typealias Value = CGFloat
        
        static internal var defaultValue: CGFloat = 0
        
        static internal func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}
