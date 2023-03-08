//
//  BottomSheetView.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI
import UIKit

struct BottomSheetView: View {
    
    var dismiss: () -> Void
    
    var body: some View {
        VStack {
            VStack{ Color.clear.onTapGesture { dismiss() } }.frame(maxWidth: .infinity, maxHeight: .infinity)

            PurchaseBottomSheet(transaction: nil, buyAction: {}, dismissAction: dismiss, setPaymentMethod: { _ in } )
            
            // Template
//            ZStack {
//                ColorsUi.APC_DarkBlue
//
//                Text("This is the bottom sheet")
//                    .foregroundColor(ColorsUi.APC_White)
//            }
//            .transition(.move(edge: .bottom))
//            .animation(.easeInOut(duration: 2))
//            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
//            .cornerRadius(13, corners: [.topLeft, .topRight])
//            .background(Color.black.opacity(0.3).ignoresSafeArea())
//            .ignoresSafeArea()
        }.ignoresSafeArea()
        
    }
}

extension BottomSheetView {
    func toUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}
