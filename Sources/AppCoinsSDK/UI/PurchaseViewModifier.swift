//
//  File.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI

struct PurchaseViewModifier: ViewModifier {
    @State private var isPresented = false
    var productIdentifier: String
    var onCompletion: ((Bool) -> Void)?
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if self.isPresented {
                        PurchaseView(productIdentifier: self.productIdentifier, onCompletion: { success in
                            self.isPresented = false
                            if let completion = self.onCompletion {
                                completion(success)
                            }
                        })
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.5))
                        .transition(.opacity)
                    }
                }
            )
            .onDisappear {
                self.isPresented = false
            }
    }
}

struct PurchaseView: View {
    var productIdentifier: String
    var onCompletion: ((Bool) -> Void)?
    
    var body: some View {
        // Your in-app purchase flow view implementation goes here
        VStack {
            Text("In-App Purchase")
                .font(.title)
                .padding()
            Button(action: {
                // Perform the purchase and handle the result
                // ...
                if let completion = self.onCompletion {
                    completion(true) // Or pass in false if the purchase fails
                }
            }) {
                Text("Purchase")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}
