//
//  File.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import SwiftUI
import URLImage

struct PaymentMethodQuickIcon: View {
    
    var icon: URL
    
    var body: some View {
        URLImage(icon,
                 inProgress: { progress in
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(ColorsUi.APC_LightGray)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                    },
                 failure: {error,retry in
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(ColorsUi.APC_LightGray)
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
