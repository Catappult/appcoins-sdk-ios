//
//  ProcessingBottomSheet.swift
//  
//
//  Created by aptoide on 08/03/2023.
//

import Foundation
import SwiftUI
import URLImage

struct ProcessingBottomSheet: View {
    
    @ObservedObject var viewModel: BottomSheetViewModel
    @State private var isPresented = false
    
    var body: some View {

        ZStack {
            ColorsUi.APC_DarkBlue
            
            VStack(spacing: 0) {
                
                Image("logo-wallet-white", bundle: Bundle.module)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: 83, height: 24)
                    .padding(.top, 24)
                
                Image(uiImage: viewModel.getAppIcon())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 83, height: 83)
                    .clipShape(Circle())
                    .padding(.top, 40)
                
                ProgressView()
                    .scaleEffect(1.75, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: ColorsUi.APC_White))
                    .padding(.top, 50)
                    .padding(.bottom, 74)
                
            }.frame(height: 348, alignment: .top)
            
            
        }.frame(width: UIScreen.main.bounds.size.width, height: 348)
            .cornerRadius(13, corners: [.topLeft, .topRight])
            .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
            .transition(.move(edge: isPresented ? .bottom : .top))
            .onAppear { withAnimation { isPresented = true } }
            .onDisappear { withAnimation { isPresented = false } }
        
    }
}
