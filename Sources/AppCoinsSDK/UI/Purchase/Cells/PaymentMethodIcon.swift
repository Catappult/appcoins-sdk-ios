//
//  PaymentMethodIcon.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import SwiftUI

internal struct PaymentMethodIcon: View {
    
    internal var icon: String
    internal var disabled: Bool
    
    internal var body: some View {
        if let icon = URL(string: icon), #available(iOS 15.0, *) {
            AsyncImage(url: icon) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(ColorsUi.APC_White)
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                    
                case .success(let image):
                    image
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 24, height: 24)
                        .opacity(disabled ? 0.2 : 1)
                    
                case .failure:
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(ColorsUi.APC_White)
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                }
            }
            .padding(.trailing, 16)
            .padding(.leading, 16)
        } else {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(ColorsUi.APC_White)
                .frame(width: 24, height: 24)
                .clipShape(Circle())
        }
    }
}
