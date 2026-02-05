//
//  PurchaseHeader.swift
//  AppCoinsSDK
//
//  Created by aptoide on 30/05/2025.
//

import SwiftUI

internal struct PurchaseHeader: View {
    
    @ObservedObject internal var viewModel: ProviderViewModel = ProviderViewModel.shared
    
    internal var body: some View {
        HStack(spacing: 0) {
                    
            VStack{}.frame(width: 24)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    PurchaseIcon()
                    
                    VStack{}.frame(width: 15)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        PurchaseTitle()
                        
                        PurchasePrice()
                        
                        VStack{}.frame(height: 4)
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
            
            CloseButton(action: viewModel.dismiss)
            
            VStack{}.frame(width: 24)
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 116 : UIScreen.main.bounds.width, height: 72)
    }
}
