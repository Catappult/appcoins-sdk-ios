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
            ColorsUi.APC_DarkBlue
            
            ProgressView()
                .scaleEffect(1.75, anchor: .center)
                .progressViewStyle(CircularProgressViewStyle(tint: ColorsUi.APC_White))
            
        }.frame(width: UIScreen.main.bounds.size.width, height: 436)
            .cornerRadius(13, corners: [.topLeft, .topRight])
            .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
            .transition(.move(edge: isPresented ? .bottom : .top))
            .onAppear { withAnimation { isPresented = true } }
    }
}
