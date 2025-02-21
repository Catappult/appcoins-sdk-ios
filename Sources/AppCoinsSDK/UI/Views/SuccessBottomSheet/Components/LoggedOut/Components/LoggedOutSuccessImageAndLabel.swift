//
//  LoggedOutSuccessImageAndLabel.swift
//
//
//  Created by aptoide on 03/01/2025.
//

import SwiftUI

internal struct LoggedOutSuccessImageAndLabel: View {
    
    internal var body: some View {
        VStack(spacing: 0) {
            Image("checkmark", bundle: Bundle.APPCModule)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .frame(width: 40, height: 40)
            
            VStack{}.frame(height: 5)
            
            Text(Constants.successText)
                .font(FontsUi.APC_Title3_Bold)
                .foregroundColor(ColorsUi.APC_Black)
        }
    }
}
