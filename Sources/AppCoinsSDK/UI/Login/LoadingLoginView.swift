//
//  File.swift
//  
//
//  Created by aptoide on 19/12/2024.
//

import SwiftUI
import ActivityIndicatorView

struct LoadingLoginView: View {
    
    var body: some View {
        ZStack {
            ActivityIndicatorView(
                isVisible: .constant(true), type: .growingArc(ColorsUi.APC_Gray, lineWidth: 1.5))
            .frame(width: 41, height: 41)
            
            Image("loading-appc-icon", bundle: Bundle.APPCModule)
                .resizable()
                .scaledToFit()
                .frame(height: 23)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}


