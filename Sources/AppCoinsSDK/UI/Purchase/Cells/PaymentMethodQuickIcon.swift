//
//  PaymentMethodQuickIcon.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import SwiftUI

internal struct PaymentMethodQuickIcon: View {
    
    internal var icon: URL
    
    internal var body: some View {
        if #available(iOS 15.0, *) {
            AsyncImage(url: icon) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(ColorsUi.APC_LightGray)
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                    
                case .success(let image):
                    image
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 24, height: 24)
                    
                case .failure:
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(ColorsUi.APC_LightGray)
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                }
            }
        } else {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(ColorsUi.APC_LightGray)
                .frame(width: 24, height: 24)
                .clipShape(Circle())
        }
    }
}
