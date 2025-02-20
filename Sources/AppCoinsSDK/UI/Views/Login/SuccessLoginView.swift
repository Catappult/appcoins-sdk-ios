//
//  SuccessLoginView.swift
//
//
//  Created by aptoide on 20/12/2024.
//

import SwiftUI

internal struct SuccessLoginView: View {
    
    internal var body: some View {
        ZStack {
            Image("checkmark", bundle: Bundle.APPCModule)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .frame(width: 50, height: 50)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .animation(.easeInOut(duration: 0.2))
    }
}
