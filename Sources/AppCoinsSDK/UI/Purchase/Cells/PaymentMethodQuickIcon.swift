//
//  PaymentMethodQuickIcon.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import SwiftUI
import URLImage

internal struct PaymentMethodQuickIcon: View {
    
    internal var icon: URL
    
    internal var body: some View {
        URLImage(icon,
                 inProgress: { progress in
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(APPCColor.lightGray)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                    },
                 failure: {error,retry in
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(APPCColor.lightGray)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                        .onAppear{ retry() }},
                 content: {
                    image in
                    image
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 48, height: 48)
                }
        )
    }
}
