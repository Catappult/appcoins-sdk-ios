//
//  DeleteAccountSuccessView.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/05/2025.
//

import SwiftUI

internal struct DeleteAccountSuccessView: View {
    
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
