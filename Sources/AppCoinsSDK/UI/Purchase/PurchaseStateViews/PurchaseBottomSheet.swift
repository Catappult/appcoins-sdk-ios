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
    
    internal var blueStripeHeight: CGFloat {
        if transactionViewModel.paymentMethodSelected != nil && transactionViewModel.paymentMethodSelected?.name != "appcoins_credits" {
            // If bonus is shown
            return 64 // 166
        } else {
            // If bonus is not shown
            return 34 // 102
        }
    }
    
    @State private var transitionEdge: Edge = .bottom
    @State private var previousBackgroundHeight: CGFloat = 0
    
    internal var baseHeight: CGFloat {
        viewModel.isLandscape ? UIScreen.main.bounds.height * 0.35 : 200// 228 // 180
    }
    internal var paymentMethodListHeight: CGFloat { return CGFloat(50*(transactionViewModel.transaction?.paymentMethods.count ?? 0)) }
    internal var quickPaymentHeight: CGFloat = 150
    
    internal var frontTransactionHeight : CGFloat {
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
    @State private var dynamicHeight: CGFloat = 250
    @State private var dynamicPadding: CGFloat = 0
    @ObservedObject private var keyboardObserver = KeyboardObserver.shared
    
    internal var backgroundHeight : CGFloat {
        return frontTransactionHeight + blueStripeHeight
    }
    
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
                        
                        HStack(spacing: 0) {
                            VStack {}.frame(width: 24)
                            
                            Image(uiImage: Utils.getAppIcon())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .frame(maxWidth: 40, alignment: .leading)
                            
                            VStack {}.frame(width: 15)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                if let title = transactionViewModel.transaction?.getTitle() {
                                    Text(title)
                                        .foregroundColor(ColorsUi.APC_Black)
                                        .font(FontsUi.APC_Body_Bold)
                                        .lineLimit(1)
                                } else {
                                    HStack(spacing: 0) {
                                        Text("")
                                            .skeleton(with: true)
                                            .frame(width: 125, height: 22, alignment: .leading)
                                        VStack {}.frame(maxWidth: .infinity)
                                    }.frame(maxWidth: .infinity)
                                }
                                
                                HStack(spacing: 0) {
                                    if let amount = transactionViewModel.transaction?.moneyAmount {
                                        Text((transactionViewModel.transaction?.moneyCurrency.sign ?? "") + String(amount))
                                            .foregroundColor(ColorsUi.APC_Black)
                                            .font(FontsUi.APC_Subheadline_Bold)
                                            .lineLimit(1)
                                        
                                        VStack {}.frame(width: 4)
                                        
                                        Text(transactionViewModel.transaction?.moneyCurrency.currency ?? "-")
                                            .foregroundColor(ColorsUi.APC_Black)
                                            .font(FontsUi.APC_Caption1_Bold)
                                            .lineLimit(1)
                                    } else {
                                        HStack(spacing: 0) {
                                            Text("")
                                                .skeleton(with: true)
                                                .frame(width: 60, height: 14, alignment: .leading)
                                            VStack {}.frame(maxWidth: .infinity)
                                        }.frame(maxWidth: .infinity)
                                    }
                                    
                                    VStack {}.frame(width: 16)
                                    
                                    if let appcAmount = transactionViewModel.transaction?.appcAmount {
                                        Text(verbatim: String(format: "%.3f", appcAmount) + " APPC")
                                            .foregroundColor(ColorsUi.APC_Gray)
                                            .font(FontsUi.APC_Caption2)
                                    } else {
                                        HStack(spacing: 0) {
                                            Text("")
                                                .skeleton(with: true)
                                                .frame(width: 55, height: 10, alignment: .leading)
                                                .padding(.top, 2)
                                            VStack {}.frame(maxWidth: .infinity)
                                        }.frame(maxWidth: .infinity)
                                    }
                                }
                                .frame(width: viewModel.isLandscape ? 256 : UIScreen.main.bounds.width - 154, alignment: .bottomLeading)
                                
                                VStack {}.frame(height: 4)
                                
                                
                            }.frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                            
                            Button {
                                viewModel.dismiss()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(ColorsUi.APC_BackgroundLightGray_Button)
                                        .frame(width: 30, height: 30)
                                    
                                    Image(systemName: "xmark")
                                        .foregroundColor(ColorsUi.APC_DarkGray_Xmark)
                                    
                                }
                            }
                            
                            VStack {}.frame(width: 24)
                        }
                        .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.width, height: 72)
                        .background(BlurView(style: .systemMaterial))
                        .frame(maxHeight: .infinity, alignment: .top)
                        
                        VStack {}.frame(height: 8)
                        
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
                        })
                }
                
                if adyenController.state == .choosingCreditCard {
                    CreditCardChoiceBottomSheet(viewModel: viewModel)
                        .onAppear(perform: {
                            print("CreditCardChoiceBottomSheet")
                        })
                }
                
                if adyenController.state == .newCreditCard {
                    CreditCardBottomSheet(viewModel: viewModel, dynamicHeight: $dynamicHeight)
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
        .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width, height: backgroundHeight)
        .padding(.bottom, keyboardObserver.isKeyboardVisible ? keyboardObserver.keyboardHeight - dynamicPadding : 0)
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
