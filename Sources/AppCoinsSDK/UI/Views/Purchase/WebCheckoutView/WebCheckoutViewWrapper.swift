//
//  WebCheckoutViewWrapper.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 20/05/2025.
//

import SwiftUI

@available(iOS 14, *)
internal struct WebCheckoutViewWrapper: View {
    
    internal var background: Color
    
    internal var body: some View {
        VStack(spacing: 0) {
            HStack{}.frame(height: 20)
            
            WebCheckoutView()
                .ignoresSafeArea(edges: .bottom)
            
        }.background(background)
    }
}
