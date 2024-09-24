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
    
    @State private var isPresented = false
    
    internal var blueStripeHeight : CGFloat {
        if transactionViewModel.paymentMethodSelected != nil && transactionViewModel.paymentMethodSelected?.name != "appcoins_credits" {
            // If bonus is shown
            return 67 // 166
        } else {
            // If bonus is not shown
            return 34 // 102
        }
    }
    
    @State private var transitionEdge : Edge = .bottom
    @State private var previousBackgroundHeight : CGFloat = 0
    
    internal var baseHeight : CGFloat = 256
    internal var paymentMethodListHeight : CGFloat { return CGFloat(44*(transactionViewModel.transaction?.paymentMethods.count ?? 0)) }
    internal var quickPaymentHeight : CGFloat = 115
    
    internal var frontTransactionHeight : CGFloat {
        if viewModel.purchaseState == .paying {
            if transactionViewModel.showOtherPaymentMethods {
                // Payment Method List is shown
                return baseHeight + paymentMethodListHeight
            } else {
                // Quick Payment Screen is shown
                if transactionViewModel.lastPaymentMethod == nil { return 257 } else { return baseHeight + quickPaymentHeight }
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
    @State private var dynamicHeight: CGFloat = 250
    @State private var dynamicPadding: CGFloat = 0
    @ObservedObject private var keyboardObserver = KeyboardObserver.shared
    
    internal var backgroundHeight : CGFloat {
        return frontTransactionHeight + blueStripeHeight
    }
    
    internal var body: some View {
        
        ZStack {
            ColorsUi.APC_DarkBlue
            
            VStack(spacing: 0) {
                
                HStack {
                    VStack(spacing: 0) {
                        
                        if transactionViewModel.paymentMethodSelected != nil && transactionViewModel.paymentMethodSelected?.name != Method.appc.rawValue {
                            
                            VStack {}.frame(height: 16)
                            
                            HStack {
                                Image("gift-pink", bundle: Bundle.module)
                                    .resizable()
                                    .edgesIgnoringSafeArea(.all)
                                    .frame(width: 16, height: 16)
                                
                                if let bonusCurrency = transactionViewModel.transaction?.bonusCurrency.sign, let bonusAmount = transactionViewModel.transaction?.bonusAmount {
                                    Text(String(format: Constants.purchaseBonus, "\(bonusCurrency)\(String(format: "%.3f", bonusAmount))"))
                                        .font(FontsUi.APC_Caption1_Bold)
                                        .foregroundColor(ColorsUi.APC_White)
                                        .frame(height: 16)
                                } else {
                                    HStack(spacing: 0) {
                                        Text("")
                                            .skeleton(with: true)
                                            .font(FontsUi.APC_Caption1_Bold)
                                            .opacity(0.1)
                                            .frame(width: 40, height: 17)
                                    }
                                }
                                
                                Image("appc-payment-method-pink", bundle: Bundle.module)
                                    .resizable()
                                    .edgesIgnoringSafeArea(.all)
                                    .frame(width: 16, height: 16)
                            }
                            
                            VStack {}.frame(height: 4)
                            
                            Text(Constants.canSeeBonusText)
                                .font(FontsUi.APC_Caption2)
                                .foregroundColor(ColorsUi.APC_Gray)
                                .frame(height: 13)
                            
                            VStack {}.frame(height: 12)
                        }
                    }
                    
                }.frame(width: UIScreen.main.bounds.size.width, height: blueStripeHeight)
                
                ZStack() {
                    ColorsUi.APC_LightGray
                    
                    if viewModel.purchaseState == .paying {
                        PaymentChoiceBottomSheet(viewModel: viewModel)
                            .onAppear(perform: {
                                print("paymentchoicebottomsheet")
                            })
                    }
                
                    if viewModel.purchaseState == .adyen {
                        if adyenController.state == .none {
                            AdyenLoadingBottomSheet(viewModel: viewModel)
                        }
                        
                        if adyenController.state == .choosingCreditCard {
                            CreditCardChoiceBottomSheet(viewModel: viewModel)
                        }
                        
                        if adyenController.state == .newCreditCard {
                            CreditCardBottomSheet(viewModel: viewModel, dynamicHeight: $dynamicHeight)
                                .onAppear{ startObservingDynamicHeight() }
                                .onDisappear{ stopObservingDynamicHeight() }
                                .frame(width: UIScreen.main.bounds.size.width, height: dynamicHeight)
                        }
                        
                        if adyenController.state == .paypal {
                            EmptyView()
                        }
                    }
                    
                }.frame(width: UIScreen.main.bounds.size.width, height: frontTransactionHeight )
                    .cornerRadius(13, corners: [.topLeft, .topRight])
                }
            
        }
        .cornerRadius(13, corners: [.topLeft, .topRight])
        .frame(width: UIScreen.main.bounds.size.width, height: backgroundHeight)
        .padding(.bottom, keyboardObserver.isKeyboardVisible ? keyboardObserver.keyboardHeight - dynamicPadding : 0)
        .modifier(MeasureBottomPositionModifier(onChange: { newValue in
            let difference = UIScreen.main.bounds.height - newValue
            dynamicPadding = difference
        }))
        // Otherwise (with a regular general animation) the skeletons animation does not work
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
