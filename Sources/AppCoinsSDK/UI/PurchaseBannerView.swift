//
//  PurchaseBannerView.swift
//
//
//  Created by Graciano Caldeira on 30/07/2024.
//

import SwiftUI

struct PurchaseBannerView: View {
    
    @ObservedObject internal var transactionViewModel: TransactionViewModel
//    var flavor: Flavor
    var height: CGFloat
    
    var body: some View {
        HStack {
            
//            DirectToConsumerBanner()
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(ColorsUi.APC_Pink)
//            
            
//            if paymentMethodType == .d2d {
//                
//            } else {
//            GamificationBanner(transactionViewModel: transactionViewModel)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(ColorsUi.APC_DarkBlue)
//            }
        }.frame(width: UIScreen.main.bounds.size.width, height: height)
            
    }
}
