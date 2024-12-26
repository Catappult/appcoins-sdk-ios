//
//  File.swift
//  
//
//  Created by aptoide on 26/12/2024.
//

import SwiftUI
@_implementationOnly import ActivityIndicatorView

struct LoadingView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            VStack{}.frame(height: 72)
            
            ZStack {
                ActivityIndicatorView(
                    isVisible: .constant(true), type: .growingArc(ColorsUi.APC_Gray, lineWidth: 1.5))
                .frame(width: 41, height: 41)
                
                Image("loading-appc-icon", bundle: Bundle.APPCModule)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 23)
            }
        }.frame(maxHeight: .infinity, alignment: .center)
    }
}
