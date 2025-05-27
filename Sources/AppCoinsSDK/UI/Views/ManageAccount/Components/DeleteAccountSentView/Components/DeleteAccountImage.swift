//
//  DeleteAccountImage.swift
//
//
//  Created by aptoide on 03/01/2025.
//

import SwiftUI

internal struct DeleteAccountImage: View {
 
    internal var body: some View {
        Image("magic-link-image", bundle: Bundle.APPCModule)
            .resizable()
            .frame(width: 105, height: 72)
    }
}
