//
//  CreditCardBottomSheet.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import Foundation
import SwiftUI
import ActivityIndicatorView

internal struct CreditCardBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var transactionViewModel: TransactionViewModel
    @ObservedObject internal var adyenController: AdyenController = AdyenController.shared
    
    @Binding internal var dynamicHeight: CGFloat
    
    internal var body: some View {
       
        VStack(spacing: 0) {
//            if viewModel.isLandscape {
//                HStack(spacing: 0) {
//                    VStack {}.frame(width: 24)
//                    
//                    Image(uiImage: Utils.getAppIcon())
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 40, height: 40)
//                        .clipShape(Circle())
//                        .frame(maxWidth: 40, alignment: .leading)
//                    
//                    VStack {}.frame(width: 15)
//                    
//                    VStack(alignment: .leading, spacing: 0) {
//                        if let title = transactionViewModel.transaction?.getTitle() {
//                            Text(title)
//                                .foregroundColor(ColorsUi.APC_Black)
//                                .font(FontsUi.APC_Body_Bold)
//                                .lineLimit(1)
//                        } else {
//                            HStack(spacing: 0) {
//                                Text("")
//                                    .skeleton(with: true)
//                                    .frame(width: 125, height: 22, alignment: .leading)
//                                VStack {}.frame(maxWidth: .infinity)
//                            }.frame(maxWidth: .infinity)
//                        }
//                        
//                        HStack(spacing: 0) {
//                            if let amount = transactionViewModel.transaction?.moneyAmount {
//                                Text((transactionViewModel.transaction?.moneyCurrency.sign ?? "") + String(amount))
//                                    .foregroundColor(ColorsUi.APC_Black)
//                                    .font(FontsUi.APC_Subheadline_Bold)
//                                    .lineLimit(1)
//                                
//                                VStack {}.frame(width: 4)
//                                
//                                Text(transactionViewModel.transaction?.moneyCurrency.currency ?? "-")
//                                    .foregroundColor(ColorsUi.APC_Black)
//                                    .font(FontsUi.APC_Caption1_Bold)
//                                    .lineLimit(1)
//                            } else {
//                                HStack(spacing: 0) {
//                                    Text("")
//                                        .skeleton(with: true)
//                                        .frame(width: 60, height: 14, alignment: .leading)
//                                    VStack {}.frame(maxWidth: .infinity)
//                                }.frame(maxWidth: .infinity)
//                            }
//                            
//                            VStack {}.frame(width: 16)
//                            
//                            if let appcAmount = transactionViewModel.transaction?.appcAmount {
//                                Text(verbatim: String(format: "%.3f", appcAmount) + " APPC")
//                                    .foregroundColor(ColorsUi.APC_Gray)
//                                    .font(FontsUi.APC_Caption2)
//                            } else {
//                                HStack(spacing: 0) {
//                                    Text("")
//                                        .skeleton(with: true)
//                                        .frame(width: 55, height: 10, alignment: .leading)
//                                        .padding(.top, 2)
//                                    VStack {}.frame(maxWidth: .infinity)
//                                }.frame(maxWidth: .infinity)
//                            }
//                        }
//                        .frame(width: viewModel.isLandscape ? 256 : UIScreen.main.bounds.width - 154, alignment: .bottomLeading)
//                        
//                        VStack {}.frame(height: 4)
//                        
//                        
//                    }.frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
//                    
//                    Button {
//                        viewModel.dismiss()
//                    } label: {
//                        ZStack {
//                            Circle()
//                                .fill(ColorsUi.APC_BackgroundLightGray_Button)
//                                .frame(width: 30, height: 30)
//                            
//                            Image(systemName: "xmark")
//                                .foregroundColor(ColorsUi.APC_DarkGray_Xmark)
//                            
//                        }
//                    }
//                    
//                    VStack {}.frame(width: 24)
//                }
//                .frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.width, height: 72)
//                .background(BlurView(style: .systemMaterial))
//                .frame(maxHeight: .infinity, alignment: .top)
//                .ignoresSafeArea(.all)
//                
//                VStack {}.frame(height: 8)
//            } else {
            BottomSheetAppHeader(viewModel: viewModel, transactionViewModel: transactionViewModel)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .ignoresSafeArea(.all)
                    .onAppear(perform: {
                        print("PortraitAppHeader")
                    })
//            }
            
            
//            VStack {}.frame(height: 16)
            
//            HStack {
//                Button {
//                    viewModel.dismiss()
//                } label: {
//                    ZStack {
//                        Circle()
//                            .fill(Color(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5)))
//                            .frame(width: 30, height: 30)
//                        Image(systemName: "xmark")
//                            .foregroundColor(Color(UIColor(red: 0.24, green: 0.24, blue: 0.24, alpha: 1)))
//                    }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
//            }
            
            if let viewController = adyenController.presentableComponent?.viewController {
                AdyenViewControllerWrapper(viewController: viewController)
                    .frame(height: dynamicHeight)
                    .background(Color.red)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            } else {
                ZStack {
                    ActivityIndicatorView(
                        isVisible: .constant(true), type: .growingArc(ColorsUi.APC_Gray, lineWidth: 1.5))
                        .frame(width: 41, height: 41)
                    
                    Image("loading-appc-icon", bundle: Bundle.module)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 23)
                }.animation(.linear(duration: 1.5).repeatForever(autoreverses: false))
            }
        }.padding(.horizontal, 16)
    }
}
