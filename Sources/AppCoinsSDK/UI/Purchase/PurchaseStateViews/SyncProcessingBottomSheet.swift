//
//  SyncProcessingBottomSheet.swift
//  
//
//  Created by aptoide on 13/10/2023.
//

import Foundation
import SwiftUI
import URLImage

internal struct SyncProcessingBottomSheet: View {
    
    @State private var isPresented = false
    
    internal var body: some View {

        ZStack {
            APPCColor.darkBlue
            
            VStack(spacing: 0) {
                
                Image("logo-wallet-white", bundle: Bundle.module)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: 83, height: 24)
                    .padding(.top, 24)
                
            }.frame(height: 314 + Utils.bottomSafeAreaHeight, alignment: .top)
            
            ProgressView()
                .scaleEffect(1.75, anchor: .center)
                .progressViewStyle(CircularProgressViewStyle(tint: APPCColor.white))
            
        }.frame(width: UIScreen.main.bounds.size.width, height: 314 + Utils.bottomSafeAreaHeight)
            .cornerRadius(13, corners: [.topLeft, .topRight])
            .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
            .transition(.move(edge: isPresented ? .bottom : .top))
            .onAppear { withAnimation { isPresented = true } }
                
    }
}
