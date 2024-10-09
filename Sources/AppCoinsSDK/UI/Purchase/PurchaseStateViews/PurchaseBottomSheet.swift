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

internal struct PurchaseBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    @ObservedObject internal var paypalViewModel: PayPalDirectViewModel = PayPalDirectViewModel.shared
    
    @State private var isPresented = false
    
//    internal var blueStripeHeight: CGFloat {
//        if transactionViewModel.paymentMethodSelected != nil && transactionViewModel.paymentMethodSelected?.name != "appcoins_credits" {
//            // If bonus is shown
//            return 64 // 166
//        } else {
//            // If bonus is not shown
//            return 34 // 102
//        }
//    }
    
    @State private var transitionEdge: Edge = .bottom
    @State private var previousBackgroundHeight: CGFloat = 0
    
    internal var baseHeight: CGFloat {
        viewModel.isLandscape ? UIScreen.main.bounds.height * 0.55 : 270//200// 228 // 180
    }
    internal var paymentMethodListHeight: CGFloat { return CGFloat(50*(transactionViewModel.transaction?.paymentMethods.count ?? 0)) }
    internal var quickPaymentHeight: CGFloat = 150
    
    internal var frontTransactionHeight: CGFloat {
        if viewModel.purchaseState == .paying {
            if transactionViewModel.showOtherPaymentMethods {
                // Payment Method List is shown
                print("base + paymentMethodLisHeight: baseHeight - \(baseHeight) + paymentMetholist: \(paymentMethodListHeight)")
                return baseHeight + paymentMethodListHeight
            } else {
                // Quick Payment Screen is shown
                print("quick paymentIsShown")
                if transactionViewModel.lastPaymentMethod == nil { return 257 } else {
                    print("quick paymentIsShown height: \(quickPaymentHeight)")
                    return baseHeight + quickPaymentHeight }
            }
        } else {
            if adyenController.state == .none {
                return 300
            } else if adyenController.state == .choosingCreditCard {
                if let stored = adyenController.session?.sessionContext.paymentMethods.stored {
                    return CGFloat(44*stored.count + 24+18+22+36+48+9+18+14+30)
                } else {
                    return 200
                }
            } else if adyenController.state == .newCreditCard {
                return dynamicHeight + 50
            } else {
                return 200
            }
        }
    }
    
    @State private var timer: Timer? = nil
    @State private var dynamicHeight: CGFloat = 420 // 250
    @State private var dynamicPadding: CGFloat = 0
    @ObservedObject private var keyboardObserver = KeyboardObserver.shared
    
//    internal var backgroundHeight : CGFloat {
//        return frontTransactionHeight + blueStripeHeight
//    }
    
    internal var body: some View {
        
        VStack(spacing: 0) {
            if viewModel.purchaseState == .paying {
                if viewModel.isLandscape {
                    ZStack(alignment: .top) {
                        VStack(spacing: 0) {
                            
                            if transactionViewModel.lastPaymentMethod != nil || transactionViewModel.showOtherPaymentMethods {
                                if (!transactionViewModel.showOtherPaymentMethods) {
                                    // landscape lastMethod
                                    LandscapeLastPaymentMethod(viewModel: viewModel)
                                } else {
                                    // landscape multiMethods
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
                            .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 - 320 : UIScreen.main.bounds.width - 48, height: 50)
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
                        .onAppear(perform: {
                            print("AdyenLoadingBottomSheet")
                            print("FrontTransation height: \(frontTransactionHeight)")
                        })
                }
                
                if adyenController.state == .choosingCreditCard {
                    CreditCardChoiceBottomSheet(viewModel: viewModel)
                        .onAppear(perform: {
                            print("CreditCardChoiceBottomSheet")
                        })
                }
                
                if adyenController.state == .newCreditCard {
                    CreditCardBottomSheet(viewModel: viewModel, transactionViewModel: transactionViewModel, dynamicHeight: $dynamicHeight, isLandscape: $viewModel.isLandscape)
                        .onAppear{ startObservingDynamicHeight() }
                        .onDisappear{ stopObservingDynamicHeight() }
                        .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width, height: dynamicHeight)
                        .onAppear(perform: {
                            print("CreditCardBottomSheet")
                        })
                }
                
                if adyenController.state == .paypal {
                    EmptyView()
                }
            }
            
        }
        .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width, height: viewModel.isLandscape ? UIScreen.main.bounds.height * 0.9 : 420) // frontTransactionHeight
        .padding(.bottom, keyboardObserver.isKeyboardVisible && !viewModel.isLandscape ? keyboardObserver.keyboardHeight - dynamicPadding : 0)
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
        .cornerRadius(13, corners: [.topLeft, .topRight])
        .modifier(MeasureBottomPositionModifier(onChange: { newValue in
            let difference = UIScreen.main.bounds.height - newValue
            dynamicPadding = difference
        }))        // Otherwise (with a regular general animation) the skeletons animation does not work
        .animation(.easeInOut(duration: 0.3), value: transactionViewModel.paymentMethodSelected != nil)
        .animation(.easeInOut(duration: 0.3), value: transactionViewModel.paymentMethodSelected?.name)
        .animation(.easeInOut(duration: 0.3), value: transactionViewModel.showOtherPaymentMethods)
        .animation(.easeInOut(duration: 0.3), value: transactionViewModel.lastPaymentMethod == nil)
        .animation(.easeInOut(duration: 0.3), value: viewModel.purchaseState == .adyen)
        .animation(.easeInOut(duration: 0.3), value: adyenController.state == .none)
        .animation(.easeInOut(duration: 0.3), value: adyenController.state == .choosingCreditCard)
        .animation(.easeInOut(duration: 0.3), value: adyenController.state == .newCreditCard)
        .animation(.easeInOut(duration: 0.3), value: adyenController.state == .paypal)
        .animation(.easeInOut(duration: 0.3), value: keyboardObserver.isKeyboardVisible)
        .animation(.easeInOut(duration: 0.3), value: dynamicPadding != 0)
        .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
        .transition(.move(edge: isPresented ? .bottom : .top))
        .onAppear { withAnimation { isPresented = true } }
        //                .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width, height: frontTransactionHeight )
        //                    .cornerRadius(13, corners: [.topLeft, .topRight])
        
        
        
    }
    
    // KVO is limited to use by NSObject subclasses
    // Combine cannot provide precise observation at the property level
    // By checking for difference between values it prevents view refresh overload
    private func startObservingDynamicHeight() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { timer in
            if let viewController = adyenController.presentableComponent?.viewController {
                for view in viewController.view.subviews {
                    for subview in view.subviews {
                        if let content = subview.subviews.first {
                            if content.bounds.height != dynamicHeight && content.bounds.height != 0 {
                                DispatchQueue.main.async {
                                    dynamicHeight = content.bounds.height
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func stopObservingDynamicHeight() {
        timer?.invalidate()
        timer = nil
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
