//
//  PaymentMethodIcon.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import SwiftUI
@_implementationOnly import URLImage

internal struct PaymentMethodIcon: View {
    
    internal var icon: String
    internal var disabled: Bool
    
    internal var body: some View {
        if let icon = URL(string: icon) {
            URLImage(icon,
                     inProgress: {
                progress in
                   RoundedRectangle(cornerRadius: 0)
                       .foregroundColor(ColorsUi.APC_White)
                       .frame(width: 24, height: 24)
                       .clipShape(Circle())
            }, failure: {
                error,retry in
                   RoundedRectangle(cornerRadius: 0)
                       .foregroundColor(ColorsUi.APC_White)
                       .frame(width: 24, height: 24)
                       .clipShape(Circle())
                        .onAppear{ retry() }
            }, content: {
                image in
                    image
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 24, height: 24)
                        .opacity(disabled ? 0.2 : 1)
            }).padding(.trailing, 16)
                .padding(.leading, 16)
        }
    }
}
