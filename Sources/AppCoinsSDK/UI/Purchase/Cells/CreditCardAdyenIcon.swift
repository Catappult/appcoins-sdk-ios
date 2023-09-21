//
//  File.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import SwiftUI
import URLImage

struct CreditCardAdyenIcon: View {
    
    var image: URL
    
    var body: some View {
 
        URLImage(image,
                 inProgress: { progress in
                    Image("card-placeholder", bundle: Bundle.module)
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 25)
                        .padding(.horizontal, 5)
                 },
                 failure: { error, retry in
                    Image("card-placeholder", bundle: Bundle.module)
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 25)
                        .padding(.horizontal, 5)
                },
                 content: {
                    image in
                    image
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 35)
                    }
            )
    }
}
