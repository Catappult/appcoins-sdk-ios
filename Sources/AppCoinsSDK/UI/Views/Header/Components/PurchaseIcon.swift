//
//  PurchaseIcon.swift
//  AppCoinsSDK
//
//  Created by aptoide on 30/05/2025.
//

import SwiftUI

internal struct PurchaseIcon: View {
    
    internal var body: some View {
        Image(uiImage: Utils.getAppIcon())
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .frame(maxWidth: 40, alignment: .leading)
    }
}
