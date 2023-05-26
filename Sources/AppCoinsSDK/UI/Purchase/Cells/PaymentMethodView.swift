//
//  File.swift
//  
//
//  Created by aptoide on 09/03/2023.
//

import Foundation
import SwiftUI
import URLImage

struct PaymentMethodView: View, Identifiable, Equatable {
    
    let id = UUID()
    let icon: String
    let name: String
    let disabled: Bool
    
    var body: some View {
        HStack(spacing: 0) {
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
                },
                         content: {
                    image in
                        image
                            .resizable()
                            .edgesIgnoringSafeArea(.all)
                            .frame(width: 24, height: 24)
                            .opacity(disabled ? 0.2 : 1)
                }).padding(.trailing, 16)
                    .padding(.leading, 8)
                    .animation(.easeIn(duration: 0.3))
            }
            
            Text(name)
                .foregroundColor(disabled ? ColorsUi.APC_Gray : ColorsUi.APC_Black)
                .font(FontsUi.APC_Subheadline)
                .lineLimit(1)
        }
    }
}
