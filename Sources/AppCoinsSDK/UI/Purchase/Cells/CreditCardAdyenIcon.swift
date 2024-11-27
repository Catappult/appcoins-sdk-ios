//
//  CreditCardAdyenIcon.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import SwiftUI

internal struct CreditCardAdyenIcon: View {
    
    internal var image: URL
    
    internal var body: some View {
        
        if #available(iOS 15.0, *) {
            AsyncImage(url: image) { phase in
                switch phase {
                case .empty:
                    Image("card-placeholder", bundle: Bundle.APPCModule)
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 25)
                        .padding(.horizontal, 5)
                    
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 35)
                    
                case .failure:
                    Image("card-placeholder", bundle: Bundle.APPCModule)
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 25)
                        .padding(.horizontal, 5)
                }
            }
        } else {
            Image("card-placeholder", bundle: Bundle.APPCModule)
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.all)
                .frame(width: 25)
                .padding(.horizontal, 5)
        }
    }
}
