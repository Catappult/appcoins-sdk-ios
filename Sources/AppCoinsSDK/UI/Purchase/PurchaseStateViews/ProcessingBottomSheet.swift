//
//  ProcessingBottomSheet.swift
//  
//
//  Created by aptoide on 08/03/2023.
//

import Foundation
import SwiftUI
import URLImage

internal struct ProcessingBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @State private var isPresented = false
    
    internal var body: some View {

        ZStack {
            ColorsUi.APC_DarkBlue
            
            VStack(spacing: 0) {
                
                Image(uiImage: Utils.getAppIcon())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 83, height: 83)
                    .clipShape(Circle())
                
                VStack {}.frame(height: 50)
                
                ProgressView()
                    .scaleEffect(1.75, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: ColorsUi.APC_White))
                
            }.frame(height: 314 + Utils.bottomSafeAreaHeight, alignment: .center)
            
            
        }.frame(width: viewModel.isLandscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width, height: viewModel.isLandscape ? UIScreen.main.bounds.height * 0.9 : 436)
            .cornerRadius(13, corners: [.topLeft, .topRight])
            .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
            .transition(.move(edge: isPresented ? .bottom : .top))
            .onAppear { withAnimation { isPresented = true } }
            .onDisappear { withAnimation { isPresented = false } }
        
    }
}
