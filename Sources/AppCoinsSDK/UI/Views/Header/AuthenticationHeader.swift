//
//  AuthenticationHeader.swift
//
//
//  Created by Graciano Caldeira on 18/12/2024.
//

import SwiftUI

internal struct AuthenticationHeader: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    internal var body: some View {
        PurchaseHeader {
            VStack(alignment: .leading, spacing: 0) {
                Text(Constants.signInAndJoinTitle)
                    .foregroundColor(ColorsUi.APC_Black)
                    .font(FontsUi.APC_Callout_Bold)
                
                VStack{}.frame(height: 2)
                
                Text(Constants.getBonusEveryPurchase)
                    .foregroundColor(ColorsUi.APC_Black)
                    .font(FontsUi.APC_Footnote)
                
            }
        }
    }
}
