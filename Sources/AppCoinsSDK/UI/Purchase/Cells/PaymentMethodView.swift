//
//  PaymentMethodView.swift
//  
//
//  Created by aptoide on 09/03/2023.
//

import Foundation
import SwiftUI

internal struct PaymentMethodView: View, Identifiable, Equatable {
    
    internal let id = UUID()
    internal let icon: String
    internal let name: String
    internal let disabled: Bool
    
    internal var body: some View {
        HStack(spacing: 0) {
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
                .padding(.leading, 8)
                .animation(.easeIn(duration: 0.3))
            } else {
                RoundedRectangle(cornerRadius: 0)
                    .foregroundColor(ColorsUi.APC_White)
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
            }
            
            Text(name)
                .foregroundColor(disabled ? ColorsUi.APC_Gray : ColorsUi.APC_Black)
                .font(FontsUi.APC_Subheadline)
                .lineLimit(1)
        }
    }
}
