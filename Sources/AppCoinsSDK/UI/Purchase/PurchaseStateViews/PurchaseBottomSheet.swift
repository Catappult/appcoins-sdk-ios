//
//  File.swift
//  
//
//  Created by aptoide on 31/08/2023.
//

import Foundation
import SwiftUI
import URLImage
import SkeletonUI

struct PurchaseBottomSheet: View {
    
    @ObservedObject var viewModel: BottomSheetViewModel
    @ObservedObject var adyenController: AdyenController = AdyenController.shared
    
    var blueStripeHeight : CGFloat {
        if viewModel.paymentMethodSelected != nil && viewModel.paymentMethodSelected?.name != "appcoins_credits" {
            // If bonus is shown
            return 166
        } else {
            // If bonus is not shown
            return 102
        }
    }
    
    @State private var transitionEdge : Edge = .bottom
    @State private var previousBackgroundHeight : CGFloat = 0
    
    var baseHeight : CGFloat = 256
    var paymentMethodListHeight : CGFloat { return CGFloat(44*(viewModel.transaction?.paymentMethods.count ?? 0)) }
    var quickPaymentHeight : CGFloat = 115
    
    var frontTransactionHeight : CGFloat {
        if viewModel.purchaseState == .paying {
            if viewModel.showOtherPaymentMethods {
                // Payment Method List is shown
                return baseHeight + paymentMethodListHeight
            } else {
                // Quick Payment Screen is shown
                if viewModel.lastPaymentMethod == nil { return 257 } else { return baseHeight + quickPaymentHeight }
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
    
    var backgroundHeight : CGFloat {
        return frontTransactionHeight + blueStripeHeight
    }
    
    var body: some View {
        
        if !(viewModel.purchaseState == .adyen && adyenController.state == .storedCreditCard) {
            ZStack {
                ColorsUi.APC_DarkBlue
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(spacing: 0) {
                            Image("logo-wallet-white", bundle: Bundle.module)
                                .resizable()
                                .edgesIgnoringSafeArea(.all)
                                .frame(width: 83, height: 24)
                                .padding(.top, viewModel.paymentMethodSelected != nil && viewModel.paymentMethodSelected?.name != "appcoins_credits" ? 24 : 0)
                            
                            if viewModel.paymentMethodSelected != nil && viewModel.paymentMethodSelected?.name != "appcoins_credits" {
                                HStack {
                                    Image("gift-1", bundle: Bundle.module)
                                        .resizable()
                                        .edgesIgnoringSafeArea(.all)
                                        .frame(width: 15, height: 15)
                                    
                                    if let bonusCurrency = viewModel.transaction?.bonusCurrency, let bonusAmount = viewModel.transaction?.bonusAmount {
                                        Text(String(format: Constants.purchaseBonus, "\(bonusCurrency)\(String(format: "%.3f", bonusAmount))"))
                                            .font(FontsUi.APC_Caption1_Bold)
                                            .foregroundColor(ColorsUi.APC_White)
                                            .frame(height: 16)
                                    } else {
                                        HStack(spacing: 0) {
                                            Text(Constants.purchaseBonusFirst)
                                                .font(FontsUi.APC_Caption1_Bold)
                                                .foregroundColor(ColorsUi.APC_White)
                                            Text(" €0.00 ")
                                                .skeleton(with: true)
                                                .font(FontsUi.APC_Caption1_Bold)
                                                .opacity(0.1)
                                                .frame(width: 40, height: 17)
                                            Text(Constants.purchaseBonusSecond)
                                                .font(FontsUi.APC_Caption1_Bold)
                                                .foregroundColor(ColorsUi.APC_White)
                                        }
                                    }
                                }.padding(.top, 17)
                                
                                Text(Constants.canSeeBonusText)
                                    .font(FontsUi.APC_Caption2)
                                    .foregroundColor(ColorsUi.APC_Gray)
                                    .frame(height: 13)
                                    .padding(.top, 6)
                            }
                            
                            HStack(spacing: 0) {
                                Image("pink-wallet", bundle: Bundle.module)
                                    .resizable()
                                    .edgesIgnoringSafeArea(.all)
                                    .frame(width: 19, height: 16)
                                Text(Constants.walletBalance)
                                    .font(FontsUi.APC_Caption1_Bold)
                                    .foregroundColor(ColorsUi.APC_Pink)
                                    .padding(.leading, 6.22)
                                if let balance = viewModel.transaction?.walletBalance {
                                    Text(balance)
                                        .font(FontsUi.APC_Caption1_Bold)
                                        .foregroundColor(ColorsUi.APC_White)
                                } else {
                                    Text("0.00€")
                                        .skeleton(with: true)
                                        .font(FontsUi.APC_Caption1_Bold)
                                        .opacity(0.1)
                                        .frame(width: 35, height: 15)
                                }
                            }.padding(.top, viewModel.paymentMethodSelected != nil && viewModel.paymentMethodSelected?.name != "appcoins_credits" ? 24 : 12)
                                .padding(.bottom, viewModel.paymentMethodSelected != nil && viewModel.paymentMethodSelected?.name != "appcoins_credits" ? 24 : 0)
                        }
                        
                    }.frame(width: UIScreen.main.bounds.size.width, height: blueStripeHeight)
                    
                    ZStack() {
                        ColorsUi.APC_LightGray
                        
                        if viewModel.purchaseState == .paying {
                            PaymentChoiceBottomSheet(viewModel: viewModel)
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
            .animation(.easeInOut(duration: 0.3), value: viewModel.paymentMethodSelected != nil)
            .animation(.easeInOut(duration: 0.3), value: viewModel.paymentMethodSelected?.name)
            .animation(.easeInOut(duration: 0.3), value: viewModel.showOtherPaymentMethods)
            .animation(.easeInOut(duration: 0.3), value: viewModel.lastPaymentMethod == nil)
            .animation(.easeInOut(duration: 0.3), value: viewModel.purchaseState == .adyen)
            .animation(.easeInOut(duration: 0.3), value: adyenController.state == .none)
            .animation(.easeInOut(duration: 0.3), value: adyenController.state == .choosingCreditCard)
            .animation(.easeInOut(duration: 0.3), value: adyenController.state == .newCreditCard)
            .animation(.easeInOut(duration: 0.3), value: adyenController.state == .paypal)
            .animation(.easeInOut(duration: 0.3), value: keyboardObserver.isKeyboardVisible)
            .animation(.easeInOut(duration: 0.3), value: dynamicPadding != 0)
        }
        
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
    
    struct MeasureBottomPositionModifier: ViewModifier {
        var onChange: (CGFloat) -> Void
        
        // Use a State variable to store the latest preference value
        @State private var debouncedValue: CGFloat = 0
        
        // Use a Timer to trigger updates at a fixed interval
        // This timer will prevent the UI from updating more than once per frame which causes some unexpected problems
        private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
        
        func body(content: Content) -> some View {
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

    struct BottomPositionPreferenceKey: PreferenceKey {
        typealias Value = CGFloat

        static var defaultValue: CGFloat = 0

        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}
