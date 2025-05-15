//
//  WebshopSuccessImageAndLabel.swift
//  
//
//  Created by aptoide on 09/05/2025.
//

import SwiftUI

internal struct WebshopSuccessImageAndLabel: View {
    
    internal var body: some View {
        VStack(spacing: 0) {
            Image("checkmark", bundle: Bundle.APPCModule)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .frame(width: 80, height: 80)
            
            VStack{}.frame(height: 16)
            
            Text(Constants.successText)
                .font(FontsUi.APC_Title3_Bold)
                .foregroundColor(ColorsUi.APC_Black)
        }
    }
}
