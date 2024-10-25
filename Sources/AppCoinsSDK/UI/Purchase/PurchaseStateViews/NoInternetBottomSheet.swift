//
//  NoInternetBottomSheet.swift
//  
//
//  Created by aptoide on 25/05/2023.
//

import Foundation
import SwiftUI

internal struct NoInternetBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    
    internal var body: some View {

        ZStack {
            ColorsUi.APC_DarkBlue
                
            VStack(spacing: 0) {
                ZStack {
                    VStack(spacing: 0) {
                        HStack {}.frame(maxHeight: .infinity)
                        
                        Image("no-internet-white", bundle: Bundle.APPCModule)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                        
                        Text(Constants.noInternetTitle)
                            .font(FontsUi.APC_Title3_Bold)
                            .foregroundColor(ColorsUi.APC_White)
                            .padding(.top, 16)
                        
                        Text(Constants.noInternetText)
                            .font(FontsUi.APC_Footnote)
                            .foregroundColor(ColorsUi.APC_White)
                            .padding(.top, 15)
                            .frame(width: UIScreen.main.bounds.width - 48)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {viewModel.reload()}) {
                            ZStack {
                                ColorsUi.APC_Pink
                                
                                Text(Constants.retryConnection)
                                    .font(FontsUi.APC_Body_Bold)
                                    .foregroundColor(ColorsUi.APC_White)
                            }.frame(width: UIScreen.main.bounds.width - 48, height: 48)
                                .cornerRadius(10)
                                .padding(.top, 54)
                        }
                        
                        HStack {}.frame(maxHeight: .infinity)
                    }
                }
            }.frame(height: 396, alignment: .top)
            
        }.frame(width: UIScreen.main.bounds.size.width, height: 396)
            .cornerRadius(13, corners: [.topLeft, .topRight])
        
    }
}
